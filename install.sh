#!/bin/bash

set -e

EXECUTOR_NAME="Macass"
INSTALL_DIR="$HOME/Applications"
TEMP_DIR=$(mktemp -d)

echo "[*] Installing $EXECUTOR_NAME..."

# FIXED: Pointed to the correct owner/repo
REPO_OWNER="ZyonUB"
REPO_NAME="macass"
ASSET_NAME="Macass.app.zip"

# FIXED: Use sed instead of grep -P for macOS compatibility
LATEST_URL=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" | \
    sed -n 's/.*"browser_download_url": "\([^"]*\).*\b'"$ASSET_NAME"'.*/\1/p' | head -n 1)

if [ -z "$LATEST_URL" ]; then
    echo "[-] Could not find download URL for $ASSET_NAME in latest release."
    exit 1
fi

echo "[+] Downloading from GitHub API: $LATEST_URL"
curl -L -o "$TEMP_DIR/$ASSET_NAME" "$LATEST_URL"

# Extract
cd "$TEMP_DIR"
unzip -q "$ASSET_NAME"

# Locate the .app bundle
APP_FILE=$(find . -name "*.app" -type d | head -n 1)
if [ -z "$APP_FILE" ]; then
    echo "[-] No .app bundle found."
    exit 1
fi

# Move to Applications
TARGET_PATH="$INSTALL_DIR/$EXECUTOR_NAME.app"
if [ -d "$TARGET_PATH" ]; then
    rm -rf "$TARGET_PATH"
fi

mv "$APP_FILE" "$TARGET_PATH"

# Remove quarantine flag so macOS doesn't block it
xattr -d com.apple.quarantine "$TARGET_PATH" 2>/dev/null || true

echo "[+] Installation complete!"
echo "[+] Launch via: open '$TARGET_PATH'"

# Cleanup
rm -rf "$TEMP_DIR"
