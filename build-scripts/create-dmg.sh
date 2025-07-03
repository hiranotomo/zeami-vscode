#!/bin/bash

# Zeami VS Code DMG Creator
# This script creates a DMG installer for macOS

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BUILD_DIR="$PROJECT_ROOT/build-output"
APP_NAME="Zeami VS Code"
DMG_NAME="Zeami-VS-Code-Installer"
VERSION=$(node -e "console.log(require('$PROJECT_ROOT/package.json').version)")

echo "Creating DMG installer for $APP_NAME v$VERSION..."

# Check if app bundle exists
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
if [ ! -d "$APP_BUNDLE" ]; then
	echo "Error: App bundle not found. Run ./build-macos.sh first."
	exit 1
fi

# Create temporary DMG contents
DMG_TEMP="$BUILD_DIR/dmg-temp"
rm -rf "$DMG_TEMP"
mkdir -p "$DMG_TEMP"

# Copy app bundle
echo "Copying app bundle..."
cp -R "$APP_BUNDLE" "$DMG_TEMP/"

# Create Applications shortcut
ln -s /Applications "$DMG_TEMP/Applications"

# Create background image directory
mkdir -p "$DMG_TEMP/.background"

# Create a simple background image placeholder
cat > "$DMG_TEMP/.background/background.png" << 'EOF'
# Placeholder for background image
EOF

# Create DS_Store for window settings (placeholder)
# In a real build, you would design the DMG window layout

# Create DMG using hdiutil
echo "Creating DMG file..."
DMG_FILE="$BUILD_DIR/$DMG_NAME-$VERSION.dmg"
DMG_TEMP_FILE="$BUILD_DIR/temp.dmg"

# Create DMG
hdiutil create -volname "$APP_NAME" \
	-srcfolder "$DMG_TEMP" \
	-ov -format UDZO \
	"$DMG_TEMP_FILE"

# Move to final location
mv "$DMG_TEMP_FILE" "$DMG_FILE"

# Clean up
rm -rf "$DMG_TEMP"

echo "DMG created successfully!"
echo "Location: $DMG_FILE"
echo ""
echo "To distribute:"
echo "1. Test the DMG by mounting it"
echo "2. Code sign the DMG (requires Apple Developer certificate)"
echo "3. Notarize the DMG (required for distribution outside App Store)"
echo ""
echo "For code signing:"
echo "  codesign --deep --force --verify --verbose --sign 'Developer ID Application: Your Name' '$DMG_FILE'"
echo ""
echo "For notarization:"
echo "  xcrun notarytool submit '$DMG_FILE' --apple-id your@email.com --team-id TEAMID --wait"