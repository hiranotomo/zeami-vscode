#!/bin/bash

# Zeami VS Code Launcher Script
# This script launches the development version of Zeami VS Code

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Node.js version check
NODE_VERSION=$(node -v | cut -d'v' -f2)
REQUIRED_VERSION="22.15.1"

# Version comparison function
version_ge() {
	[ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# Verify Node.js version
if ! version_ge "$NODE_VERSION" "$REQUIRED_VERSION"; then
	echo "Warning: Node.js v$REQUIRED_VERSION or higher is required (current: v$NODE_VERSION)"
	echo "Please run: nvm use 22.15.1"
	exit 1
fi

# Check build status
if [ ! -d "$SCRIPT_DIR/out" ]; then
	echo "Build required. Building..."
	cd "$SCRIPT_DIR"
	npm run compile
	if [ $? -ne 0 ]; then
		echo "Build failed"
		exit 1
	fi
fi

echo "Starting Zeami VS Code..."
cd "$SCRIPT_DIR"
./scripts/code.sh "$@"