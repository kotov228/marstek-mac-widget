#!/bin/zsh
set -euo pipefail
zsh Tests/test_manual_payload.sh
python3 Tests/test_mode_api.py
swift build -c release
app="$PWD/Marstek Widget.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp .build/arm64-apple-macosx/release/MarstekMacWidget "$app/Contents/MacOS/MarstekMacWidget"
cp Info.plist "$app/Contents/Info.plist"
cp -R Resources/. "$app/Contents/Resources/"
if [[ -n "${APP_VERSION:-}" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${APP_VERSION}" "$app/Contents/Info.plist"
fi
xattr -cr "$app" 2>/dev/null || true
codesign --force --deep --sign - "$app" >/dev/null
echo "Built: $app"
