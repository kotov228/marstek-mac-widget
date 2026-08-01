# 🔋 Marstek Mac Widget

A native macOS menu bar application for monitoring and controlling a Marstek
Venus energy storage station on the local network. The widget talks directly to
the station's Local/Open API through UDP port `30000`; normal telemetry,
history, station discovery, and supported controls do not require a Marstek
cloud account.

## 🚀 Highlights in v1.2.0

- More resilient Local API polling: serial UDP requests, response validation,
  retries, and longer waits for slow `ES.GetMode` responses.
- A compact native Settings window with English, Ukrainian, and German
  localization.
- Per-station mode and DOD persistence, so a temporary API gap does not blank
  the active mode or reset the edited DOD value.
- Safer Manual-mode controls, signed power display, BLE diagnostic flow, and
  broader regression coverage.

## ✨ What it can do

### 📊 Live battery monitoring

- Shows the battery state of charge directly in the macOS menu bar.
- Displays the current state: charging, discharging, or waiting.
- Refreshes telemetry once per minute to keep the display stable and avoid
  excessive requests.
- Shows temperature, usable capacity, rated capacity, grid power, and load
  power when those values are available.
- Keeps the last confirmed station mode visible during a temporary Local API
  delay, while retaining the raw response in the local log.
- Uses different colors for charging, discharging, and waiting states.

### 📈 History graph

Click the menu bar widget to open the history window.

- Select a range from the last hour, 6 hours, 24 hours, or 7 days.
- Uses a dynamic time-axis step appropriate for the selected range.
- Plots state of charge and battery capacity in kWh.
- Colors points and segments according to charging, discharging, or waiting.
- Click any point to see its exact time, charge percentage, capacity, state, and
  power.
- In Manual mode, shows the configured signed setpoint next to the mode
  (`−` charge / `+` discharge).
- Keeps the graph usable when telemetry is temporarily unavailable.

### ⚙️ Station settings

The Settings button provides local station controls:

- 🌱 **Self-consumption** mode.
- 🤖 **AI optimization** mode.
- 🛠️ **Manual** mode with configurable power from `−2500` to `+2500 W`.
- 🔌 **UPS** mode with the station's UPS charging range shown in the UI.
- 🔋 **DOD** (depth of discharge) editing from `30%` to `88%`, with a visible
  reserve calculation. The value is saved per station only after `DOD.SET`
  confirms success.
- 🌐 Automatic station discovery on the local network.
- ✏️ Manual IP address entry when discovery is unavailable.
- 💡 Current station status and saved connection details.
- 🌍 Language selection: English, Ukrainian, or German.
- 🔄 Check for the latest GitHub release and download the update ZIP.

The station IP is discovered automatically at launch and saved locally. A
previously discovered address is used only as a temporary fallback when the
station does not answer discovery. If several unknown stations respond, the app
does not choose one arbitrarily: select the intended IP in Settings.

> **Local API limitation:** the current firmware accepts DOD changes but does
> not return the current DOD through the Local API. The Settings field therefore
> shows the last value confirmed by this widget; leave it unchanged unless you
> want to change DOD.

> **UPS limitation:** the widget shows the UPS charging-power range, but this
> firmware does not expose UPS charge-power control through the Local/Open API.
> Change that value in the official Marstek app.

### 🧪 BMS diagnostics over BLE

The optional BMS screen reads diagnostics directly from a nearby Marstek
station over Bluetooth Low Energy (BLE):

- BMS firmware version.
- Battery voltage and current.
- Battery and MOSFET temperatures.
- Design capacity.
- Error and warning status.
- Individual cell voltages.

Bluetooth access is requested only when BMS diagnostics are opened. The normal
Local API widget does not need Bluetooth permissions.

## ✅ Requirements

- macOS 13 or later.
- A Marstek Venus station with `Open API` enabled in the Marstek mobile app.
- Mac and station connected to the same local network.
- Bluetooth enabled only if BLE diagnostics are needed.

## 📦 Install a release

Download the latest ZIP from the
[GitHub Releases page](https://github.com/kotov228/marstek-mac-widget/releases),
then extract `Marstek Widget.app`.

Because the release is ad-hoc signed, macOS may show a Gatekeeper warning the
first time it is opened. The following universal command removes the quarantine
attribute and launches the app from Downloads:

```sh
app_path="$HOME/Downloads/Marstek Widget.app"
xattr -dr com.apple.quarantine "$app_path"
open "$app_path"
```

To move it to `/Applications`, allow the launch, and open it in one step:

```sh
app_path="$HOME/Downloads/Marstek Widget.app"
app_destination="/Applications/Marstek Widget.app"
sudo ditto "$app_path" "$app_destination"
sudo xattr -dr com.apple.quarantine "$app_destination"
open "$app_destination"
```

The `sudo` command may ask for the macOS login password. After installation,
the widget can be launched normally from Applications or Spotlight.

## 🔄 In-app updates

Open the widget, click **Settings**, and choose **Check for updates**. The app
checks the latest release from GitHub, downloads its ZIP to `~/Downloads`, and
reveals the file in Finder. Extract the new application and replace the old one
in `/Applications` if desired.

## 🛠️ Build and run from source

Requirements for development:

- macOS 13 or later.
- Swift 5.9 or later.
- Xcode Command Line Tools or Xcode.

Run directly from the Swift package:

```sh
swift run
```

Build the application bundle, run regression checks, sign it ad-hoc, and open
it:

```sh
./build-app.sh
open "Marstek Widget.app"
```

The build script runs the payload and mode-transition tests before compiling
the application and copies all localization files into the app bundle.

## 🌐 Local API and discovery

Enable `Open API` in the Marstek app first. On every launch, the widget sends a
local discovery broadcast, reuses the saved station when it responds, and saves
the selected IP address in macOS user defaults. No station IP is hardcoded in
the application.

Normal telemetry uses the Marstek Local API over UDP port `30000`. Requests are
sent serially with pacing and retries because Venus firmware can delay or drop
back-to-back UDP datagrams. The app does not depend on the Marstek cloud for
battery status, history, station discovery, or supported operating-mode
controls.

## 🧪 Tests

Run static payload and transition checks without changing the station:

```sh
python3 Tests/test_mode_api.py
```

Run a live Local API test against a station. This changes operating modes and
restores the explicitly selected mode when finished:

```sh
python3 -u Tests/test_mode_api.py \
  --host <MARSTEK_IP> \
  --restore Manual \
  --live
```

The live test covers all 12 directed transitions between Auto, AI, Manual, and
UPS. On Venus E firmware 148, Manual commands may be acknowledged with
`set_result = 1` while `ES.GetMode` still reports `UPS`; the test reports this
explicitly as `ACK_ONLY`. For this exact firmware mismatch, the widget keeps
the acknowledged `Manual` mode visible while retaining the raw `UPS` response
in `/tmp/marstek-widget.log`; other reported modes are not overridden.

## 🤖 GitHub Actions and releases

- Every push to `main` runs regression checks and a macOS 26 build.
- Pull request builds use the protected `maintainer-approval` environment.
- Release builds package `Marstek Widget.app` as a ZIP archive.
- GitHub release notes are generated automatically.
- Releases are created from version tags and can be triggered only by the
  repository owner.

Publish a release with:

```sh
git tag -a v1.2.0 -m "Marstek Mac Widget v1.2.0"
git push origin v1.2.0
```

## 🗂️ Project layout

- `Sources/MarstekMacWidget/main.swift` — macOS application, UI, Local API
  client, graph, settings, and BLE diagnostics.
- `Sources/MarstekMacWidget/Localization.swift` — localization and update
  release helpers.
- `Resources/*/Localizable.strings` — English, Ukrainian, and German strings.
- `Tests/test_manual_payload.sh` — Manual payload regression checks.
- `Tests/test_mode_api.py` — Local API payload and live transition tests.
- `build-app.sh` — test, build, bundle, and ad-hoc signing script.

## 🤝 Community

- Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.
- Participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).
- Report vulnerabilities according to the [Security Policy](SECURITY.md), not
  in a public issue.

## 📄 License

Released under the [MIT License](LICENSE). The project is provided as-is for
local Marstek station monitoring and control. Use operating-mode controls
carefully and verify changes in the official Marstek application.
