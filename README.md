# Marstek Mac Widget

A native macOS menu bar widget for Marstek Venus energy storage systems. The
widget communicates directly with the station through the Marstek Open API
over UDP port `30000`.

## Requirements

- macOS 13 or later
- Swift 5.9 or later
- A Marstek station with the local/Open API enabled
- Mac and station connected to the same local network

Enable `Open API` in the Marstek mobile application before starting the
widget.

## Build and run

Run directly from the package:

```sh
swift run
```

Build the signed application bundle:

```sh
./build-app.sh
open "Marstek Widget.app"
```

`build-app.sh` runs the regression tests before compiling the application and
copies the localization files into the application bundle.

## Opening a downloaded release

The release ZIP is ad-hoc signed, so macOS Gatekeeper may show a warning the
first time the application is opened. If the app was extracted into
`~/Downloads`, remove the quarantine attribute and open it with:

```sh
app_path="$HOME/Downloads/Marstek Widget.app"
xattr -dr com.apple.quarantine "$app_path"
open "$app_path"
```

If the application is stored elsewhere, replace the value of `app_path` with
its path. This is required only for the ad-hoc signed release build.

To move it to the system Applications folder, remove the quarantine attribute,
and launch it in one step:

```sh
app_path="$HOME/Downloads/Marstek Widget.app"
app_destination="/Applications/Marstek Widget.app"
sudo ditto "$app_path" "$app_destination"
sudo xattr -dr com.apple.quarantine "$app_destination"
open "$app_destination"
```

The `sudo` command may ask for your macOS login password. After this, launch
the widget normally from Applications or Spotlight.

## GitHub Actions and releases

Every push and pull request targeting `main` runs the regression checks and a
macOS build through GitHub Actions.

Pull request builds use a protected `maintainer-approval` environment and wait
for repository-owner approval before running. Releases can only be triggered
by the repository owner.

To publish a release, push a version tag:

```sh
git tag v1.0.0
git push origin v1.0.0
```

The release workflow builds the application, packages `Marstek Widget.app` as
a ZIP archive, and creates a GitHub Release with generated release notes.

## Network discovery

On every launch, the widget broadcasts a discovery request on the local
network. The first Marstek station found is saved as the current IP address and
is then used for telemetry requests. If discovery temporarily receives no
response, the last discovered address is used as a fallback. The address can
also be changed manually or discovered again from Settings.

The discovery process does not require a hardcoded station IP.

## Features

- Battery state of charge and charging/discharging status
- Battery power, temperature, capacity, and available energy data
- Historical graph with selectable time ranges and point details
- Charging/discharging/idle status shown with different colors
- Local operating-mode controls for Auto, AI, Manual, and UPS
- Manual power control from `−2500` to `+2500` W
- BMS diagnostics over Bluetooth Low Energy (BLE), including cell voltages,
  temperatures, current, voltage, errors, and warnings
- English, Ukrainian, and German application languages

BLE access is requested only when the BMS diagnostics screen is opened.

## Tests

Run the payload and transition-matrix checks without changing the station:

```sh
python3 Tests/test_mode_api.py
```

Run a live Local API test against a station. This changes operating modes and
restores Manual mode when finished:

```sh
python3 -u Tests/test_mode_api.py \
  --host <MARSTEK_IP> \
  --restore Manual \
  --live
```

The live test covers all 12 directed transitions between the four supported
modes. On Venus E firmware 148, Manual commands can be acknowledged with
`set_result = 1` while `ES.GetMode` still reports `UPS`; the test reports this
case explicitly as `ACK_ONLY`.

## Project layout

- `Sources/MarstekMacWidget/main.swift` — application and Local API client
- `Sources/MarstekMacWidget/Localization.swift` — localization loader
- `Resources/*/Localizable.strings` — English, Ukrainian, and German strings
- `Tests/test_manual_payload.sh` — Manual payload regression checks
- `Tests/test_mode_api.py` — Local API payload and live transition tests
- `build-app.sh` — test, build, bundle, and signing script
