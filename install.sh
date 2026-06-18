#!/usr/bin/env bash
# Claudio installer — downloads the latest release and installs it to /Applications.
#
#   curl -fsSL https://raw.githubusercontent.com/hassan4702/claudio/main/install.sh | bash
#
set -euo pipefail

REPO="hassan4702/claudio"
APP="Claudio.app"
DEST="/Applications/$APP"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading the latest Claudio…"
curl -fsSL "https://github.com/$REPO/releases/latest/download/Claudio.zip" -o "$TMP/Claudio.zip"

echo "Installing to /Applications…"
pkill -x Claudio 2>/dev/null || true
ditto -x -k "$TMP/Claudio.zip" "$TMP/extracted"
# Strip the Gatekeeper quarantine flag so it opens without a warning.
xattr -dr com.apple.quarantine "$TMP/extracted/$APP" 2>/dev/null || true
rm -rf "$DEST"
mv "$TMP/extracted/$APP" "$DEST"

echo "Launching Claudio…"
open "$DEST"
echo "✅ Installed. Click the 🔔 in your menu bar, then 'Enable Claude sounds'."
