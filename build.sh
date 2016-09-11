#!/bin/sh

# This script builds Snk for distribution.
# It first builds the app and then creates two
# ZIP files and a Sparkle appcast XML file which
# it places on the Desktop. Those files can then
# all be uploaded to the web.

# Get the bundle version from the plist.
PLIST_FILE="Snk/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $PLIST_FILE)

# Set up file names and paths.
BUILD_PATH=$(mktemp -dt "Snk")
SPARKLE_ZIP_NAME="Snk-$VERSION.zip"
SPARKLE_ZIP_PATH1="$HOME/Desktop/$SPARKLE_ZIP_NAME"
SPARKLE_ZIP_PATH2="$HOME/Desktop/Snk.zip"
SPARKLE_XML_PATH="$HOME/Desktop/snk.xml"

# Build Snk in a temporary build location.
xcodebuild -scheme Snk \
           -configuration Release \
           -derivedDataPath "$BUILD_PATH" \
           build

# Compress the app.
cd "$BUILD_PATH/Build/Products/Release"
rm -f "$SPARKLE_ZIP_PATH1"
rm -f "$SPARKLE_ZIP_PATH2"
zip -r -y "$SPARKLE_ZIP_PATH1" Snk.app
cp "$SPARKLE_ZIP_PATH1" "$SPARKLE_ZIP_PATH2"

# Get the date and zip file size for the Sparkle XML.
DATE=$(TZ=GMT date)
FILESIZE=$(stat -f "%z" "$SPARKLE_ZIP_PATH1")

# Make the Sparkle appcast XML file.
cat > "$SPARKLE_XML_PATH" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss
  version="2.0"
  xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"
  xmlns:dc="http://purl.org/dc/elements/1.1/" >
<channel>
<title>Snk Changelog</title>
<link>https://s3.amazonaws.com/mowglii/snk.xml</link>
<description>Most recent changes</description>
<language>en</language>
<item>
<title>Version $VERSION</title>
<sparkle:minimumSystemVersion>10.10</sparkle:minimumSystemVersion>
<sparkle:releaseNotesLink>https://mowglii.com/snk/changelog.html</sparkle:releaseNotesLink>
<pubDate>$DATE +0000</pubDate>
<enclosure
  url="https://s3.amazonaws.com/mowglii/$SPARKLE_ZIP_NAME"
  sparkle:version="$VERSION"
  length="$FILESIZE"
  type="application/octet-stream" />
</item>
</channel>
</rss>
EOF

