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
ZIP_NAME="Snk-$VERSION.zip"
ZIP_PATH1="$HOME/Desktop/$ZIP_NAME"
ZIP_PATH2="$HOME/Desktop/Snk.zip"
XML_PATH="$HOME/Desktop/snk.xml"

# Build an archive and put it in Snk.xcarchive.
xcodebuild -scheme Snk clean archive -archivePath Snk

# Go into the archive we just made.
cd Snk.xcarchive/Products/Applications

# Compress the app.
rm -f "$ZIP_PATH1"
rm -f "$ZIP_PATH2"
zip -r -y "$ZIP_PATH1" Snk.app
cp "$ZIP_PATH1" "$ZIP_PATH2"

# Get the date and zip file size for the Sparkle XML.
DATE=$(TZ=GMT date)
FILESIZE=$(stat -f "%z" "$ZIP_PATH1")

# Make the Sparkle appcast XML file.
cat > "$XML_PATH" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss 
version="2.0" 
xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" 
xmlns:dc="http://purl.org/dc/elements/1.1/" >
<channel>
<title>Snk Changelog</title>
<link>http://s3.amazonaws.com/mowglii/snk.xml</link>
<description>Most recent changes</description>
<language>en</language>
<item>
<title>Version $VERSION</title>
<sparkle:minimumSystemVersion>10.10</sparkle:minimumSystemVersion>
<sparkle:releaseNotesLink>https://mowglii.com/snk/changelog.html</sparkle:releaseNotesLink>
<pubDate>$DATE +0000</pubDate>
<enclosure 
url="https://s3.amazonaws.com/mowglii/$ZIP_NAME"
sparkle:version="$VERSION" 
length="$FILESIZE" 
type="application/octet-stream" />
</item>
</channel>
</rss>
EOF

