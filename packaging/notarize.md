# Signing, notarizing, and packaging Claudio

These steps need an Apple Developer account ($99/yr) and a "Developer ID
Application" certificate in your Keychain. Run them after `./packaging/build-app.sh`.

1. Sign with a hardened runtime:
   codesign --deep --force --options runtime \
     --sign "Developer ID Application: YOUR NAME (TEAMID)" Claudio.app

2. Create a DMG:
   hdiutil create -volname Claudio -srcfolder Claudio.app -ov -format UDZO Claudio.dmg

3. Notarize (store credentials once with `xcrun notarytool store-credentials`):
   xcrun notarytool submit Claudio.dmg --keychain-profile "claudio" --wait

4. Staple the ticket so it verifies offline:
   xcrun stapler staple Claudio.dmg

5. Verify:
   spctl -a -t open --context context:primary-signature -v Claudio.dmg

Upload `Claudio.dmg` to a GitHub Release.
