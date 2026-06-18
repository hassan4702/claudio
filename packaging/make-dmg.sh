#!/usr/bin/env bash
# Build Claudio.app and package it into a drag-to-install Claudio.dmg.
set -euo pipefail
cd "$(dirname "$0")/.."

./packaging/build-app.sh

rm -rf dmg-staging Claudio.dmg
mkdir dmg-staging
cp -R Claudio.app dmg-staging/
ln -s /Applications dmg-staging/Applications
hdiutil create -volname Claudio -srcfolder dmg-staging -ov -format UDZO Claudio.dmg
rm -rf dmg-staging

echo "Built Claudio.dmg"
