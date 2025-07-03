#!/bin/bash

# Zeami VS Code Code Signing Script
# This script signs the app for distribution

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BUILD_DIR="$PROJECT_ROOT/build-output"
APP_NAME="Zeami VS Code"

# Configuration - Set these environment variables
SIGNING_IDENTITY="${CODESIGN_IDENTITY:-}"
ENTITLEMENTS_FILE="$PROJECT_ROOT/build-scripts/entitlements.plist"

echo "Code signing $APP_NAME..."

# Check if signing identity is set
if [ -z "$SIGNING_IDENTITY" ]; then
	echo "Warning: CODESIGN_IDENTITY not set. Skipping code signing."
	echo "To sign, set: export CODESIGN_IDENTITY='Developer ID Application: Your Name'"
	exit 0
fi

# Check if app bundle exists
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
if [ ! -d "$APP_BUNDLE" ]; then
	echo "Error: App bundle not found at $APP_BUNDLE"
	exit 1
fi

# Create entitlements file if it doesn't exist
if [ ! -f "$ENTITLEMENTS_FILE" ]; then
	echo "Creating entitlements file..."
	cat > "$ENTITLEMENTS_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.cs.allow-unsigned-executable-memory</key>
	<true/>
	<key>com.apple.security.cs.allow-jit</key>
	<true/>
	<key>com.apple.security.cs.disable-library-validation</key>
	<true/>
	<key>com.apple.security.cs.disable-executable-page-protection</key>
	<true/>
	<key>com.apple.security.automation.apple-events</key>
	<true/>
</dict>
</plist>
EOF
fi

# Sign the app bundle
echo "Signing app bundle..."
codesign --deep --force --verify --verbose \
	--sign "$SIGNING_IDENTITY" \
	--options runtime \
	--entitlements "$ENTITLEMENTS_FILE" \
	"$APP_BUNDLE"

# Verify the signature
echo "Verifying signature..."
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

echo "Code signing complete!"
echo ""
echo "Next steps:"
echo "1. Create DMG: ./build-scripts/create-dmg.sh"
echo "2. Sign the DMG"
echo "3. Notarize for distribution"