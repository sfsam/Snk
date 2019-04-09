#!/bin/sh

# Get the bundle version from the plist.
PLIST_FILE="Snk/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $PLIST_FILE)
SHORT_VERSION_STRING=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $PLIST_FILE)

# Set up file names and paths.
SNK_APP_PATH="$HOME/Desktop/Snk.app"
SPARKLE_ZIP_NAME="Snk-$SHORT_VERSION_STRING.zip"
OUTPUT_DIR="$HOME/Desktop/Snk-$SHORT_VERSION_STRING"
SPARKLE_ZIP_PATH1="$OUTPUT_DIR/$SPARKLE_ZIP_NAME"
SPARKLE_ZIP_PATH2="$OUTPUT_DIR/Snk.zip"
SPARKLE_XML_PATH="$OUTPUT_DIR/snk.xml"

if [ -d "$SNK_APP_PATH" ]
then
	echo "Making zips and appcast..."
else
    echo ""
	echo "$SNK_APP_PATH: NOT FOUND!"
    echo ""
    echo "Export notarized Snk.app to Desktop."
    echo "See BUILD.txt for instructions."
    echo ""
    exit 1
fi

# Make output dir (if necessary) and clear its contents.
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR/*"

# Compress Snk.app and make a copy without version suffix.
ditto -c -k --rsrc --keepParent "$SNK_APP_PATH" "$SPARKLE_ZIP_PATH1"
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
<title>Version $SHORT_VERSION_STRING</title>
<sparkle:minimumSystemVersion>10.10</sparkle:minimumSystemVersion>
<sparkle:releaseNotesLink>https://mowglii.com/snk/changelog.html</sparkle:releaseNotesLink>
<pubDate>$DATE +0000</pubDate>
<enclosure
  url="https://s3.amazonaws.com/mowglii/$SPARKLE_ZIP_NAME"
  sparkle:version="$VERSION"
  sparkle:shortVersionString="$SHORT_VERSION_STRING"
  length="$FILESIZE"
  type="application/octet-stream" />
</item>
</channel>
</rss>
EOF

echo "Done!"

open -R "$OUTPUT_DIR/snk.xml"

