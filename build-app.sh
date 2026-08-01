#!/bin/zsh
set -euo pipefail
zsh Tests/test_manual_payload.sh
python3 Tests/test_mode_api.py
swift test -c release
swift build -c release
binary_directory="$(swift build -c release --show-bin-path)"
repo_app="$PWD/Marstek Widget.app"
if [[ "${CI:-false}" == "true" ]]; then
  output_directory="$PWD"
else
  output_directory="${MARSTEK_APP_OUTPUT_DIR:-${TMPDIR%/}/marstek-mac-widget-build}"
fi
app="$output_directory/Marstek Widget.app"
mkdir -p "$output_directory"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$binary_directory/MarstekMacWidget" "$app/Contents/MacOS/MarstekMacWidget"
cp Info.plist "$app/Contents/Info.plist"
cp -R Resources/. "$app/Contents/Resources/"
if [[ -n "${APP_VERSION:-}" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${APP_VERSION}" "$app/Contents/Info.plist"
fi
xattr -cr "$app" 2>/dev/null || true
codesign --force --deep --sign - "$app" >/dev/null
codesign --verify --deep --strict "$app"
if [[ "$app" != "$repo_app" ]]; then
  rm -rf "$repo_app"
  ln -s "$app" "$repo_app"
  codesign --verify --deep --strict "$repo_app"
fi
echo "Built: $app"
