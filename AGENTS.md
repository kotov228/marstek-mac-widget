# AGENTS.md

## Project overview

Marstek Mac Widget is a native Swift macOS menu bar application for Marstek
Venus stations. Normal telemetry and station controls use the Marstek Local
API over UDP port `30000`. BLE is used only for optional BMS diagnostics.

## Development rules

- Keep the application local-first. Do not add cloud dependencies for normal
  battery telemetry or station control.
- Do not hardcode a station IP address. Use local discovery and persist the
  last discovered address as a fallback.
- Preserve the one-minute telemetry refresh interval unless the user explicitly
  requests a different interval.
- Keep all user-facing strings in `Resources/*/Localizable.strings` for English,
  Ukrainian, and German. Do not add new UI text only to Swift source.
- Keep BLE initialization lazy so the application does not request Bluetooth
  permission at launch.
- Do not silently change the station's operating mode or power settings. Mode
  changes must be explicit and their result must be verified when possible.
- Keep release and Gatekeeper instructions up to date when packaging changes.

## Validation

Before committing Swift or API changes, run:

```sh
./build-app.sh
```

This runs the static payload checks, the mode transition checks, and the
release build. For a compiler-only check, use:

```sh
swift build -c release
```

Live station tests change operating modes. Run them only with an explicit
station host and restore the requested mode afterward:

```sh
python3 -u Tests/test_mode_api.py \
  --host <MARSTEK_IP> \
  --restore Manual \
  --live
```

## Packaging and releases

- Build locally with `./build-app.sh`.
- The application is ad-hoc signed unless a future release process adds
  notarization.
- Release ZIPs are created by `.github/workflows/release.yml` from `v*` tags.
- `main` is protected: changes must go through a pull request, approval, and
  the required GitHub Actions check.
- Do not force-push or rewrite published history.

## Files to know

- `Sources/MarstekMacWidget/main.swift` — application UI, Local API client,
  graph, settings, and BLE diagnostics.
- `Sources/MarstekMacWidget/Localization.swift` — localization loader,
  release metadata, and update helpers.
- `Resources/*/Localizable.strings` — all user-facing translations.
- `Tests/test_manual_payload.sh` — Manual API payload regression checks.
- `Tests/test_mode_api.py` — mode payload and live transition tests.
- `build-app.sh` — test, build, bundle, and signing entry point.
