#!/bin/bash

# Zeami VS Code macOS Build Script
# This script builds VS Code for macOS and creates a distributable app

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BUILD_DIR="$PROJECT_ROOT/build-output"
APP_NAME="Zeami VS Code"

echo "Building Zeami VS Code for macOS..."

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2)
REQUIRED_VERSION="22.15.1"

if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]]; then
	echo "Error: Node.js v$REQUIRED_VERSION or higher is required (current: v$NODE_VERSION)"
	exit 1
fi

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Install dependencies if needed
if [ ! -d "$PROJECT_ROOT/node_modules" ]; then
	echo "Installing dependencies..."
	cd "$PROJECT_ROOT"
	npm install
fi

# Build TypeScript
echo "Building TypeScript..."
cd "$PROJECT_ROOT"
npm run compile

# Build VS Code for macOS using gulp
echo "Building VS Code for macOS (this may take a while)..."
# Try to build with gulp, fallback to simple copy if fails
if npm run gulp vscode-darwin-arm64 2>/dev/null; then
	echo "Gulp build successful"
	APP_SOURCE="../VSCode-darwin-arm64"
else
	echo "Gulp build failed, using development build..."
	APP_SOURCE="$PROJECT_ROOT"
fi

# Create app bundle structure
echo "Creating app bundle..."
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
mkdir -p "$APP_BUNDLE/Contents/Frameworks"

# Copy Info.plist
cp "$PROJECT_ROOT/Zeami VS Code.app/Contents/Info.plist" "$APP_BUNDLE/Contents/"

# Create main executable
cat > "$APP_BUNDLE/Contents/MacOS/zeami-vscode" << 'EOF'
#!/bin/bash
# Zeami VS Code Launcher
APP_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../.. && pwd )"
VSCODE_PATH="$APP_PATH/Contents/Resources/vscode"

# Set environment
export VSCODE_PORTABLE="$APP_PATH/Contents/Resources/portable"
export ELECTRON_RUN_AS_NODE=1

# Launch VS Code
cd "$VSCODE_PATH"
exec "./scripts/code.sh" "$@"
EOF

chmod +x "$APP_BUNDLE/Contents/MacOS/zeami-vscode"

# Copy VS Code files to Resources
echo "Copying VS Code files..."
VSCODE_DEST="$APP_BUNDLE/Contents/Resources/vscode"
mkdir -p "$VSCODE_DEST"

# Copy essential files
cp -R "$PROJECT_ROOT/out" "$VSCODE_DEST/"
cp -R "$PROJECT_ROOT/scripts" "$VSCODE_DEST/"
cp -R "$PROJECT_ROOT/extensions" "$VSCODE_DEST/"
cp -R "$PROJECT_ROOT/extensions-extra" "$VSCODE_DEST/" 2>/dev/null || true
cp -R "$PROJECT_ROOT/resources" "$VSCODE_DEST/"
cp "$PROJECT_ROOT/package.json" "$VSCODE_DEST/"
cp "$PROJECT_ROOT/product.json" "$VSCODE_DEST/"
cp "$PROJECT_ROOT/zeami-extensions.json" "$VSCODE_DEST/" 2>/dev/null || true

# Copy node_modules (selective copy to reduce size)
echo "Copying dependencies..."
mkdir -p "$VSCODE_DEST/node_modules"
# Copy only production dependencies
cd "$PROJECT_ROOT"
npm list --prod --json | jq -r '.dependencies | keys[]' | while read dep; do
	if [ -d "node_modules/$dep" ]; then
		cp -R "node_modules/$dep" "$VSCODE_DEST/node_modules/"
	fi
done 2>/dev/null || cp -R node_modules "$VSCODE_DEST/"

# Create portable data directory
mkdir -p "$APP_BUNDLE/Contents/Resources/portable"

# Create a simple icon (placeholder)
touch "$APP_BUNDLE/Contents/Resources/zeami-vscode.icns"

echo "Build complete! App bundle created at: $APP_BUNDLE"
echo ""
echo "To test the app:"
echo "  open '$APP_BUNDLE'"
echo ""
echo "To create a DMG, run:"
echo "  ./build-scripts/create-dmg.sh"