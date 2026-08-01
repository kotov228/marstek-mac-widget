# Contributing to Marstek Mac Widget

Thanks for helping improve the widget. This project is a native Swift macOS
application for local-only Marstek Venus monitoring and supported controls.

## Before you start

- Read [AGENTS.md](AGENTS.md) for project rules and validation commands.
- Search existing issues and pull requests before opening a new one.
- Keep each contribution focused on one problem or feature.
- Discuss significant UI, Local API, BLE, or release-process changes in an
  issue before investing substantial implementation time.

## Development setup

Requirements:

- macOS 13 or later.
- Swift 5.9 or later.
- Xcode Command Line Tools or Xcode.

Build the release bundle and run the regression suite:

```sh
./build-app.sh
```

For a quicker compiler-only check:

```sh
swift build -c release
```

## Project rules

- Keep normal telemetry and controls local-first; do not add cloud dependencies
  for the station's everyday operation.
- Never hardcode a station IP address.
- Preserve the one-minute telemetry refresh interval unless the change is
  explicitly intended and documented.
- Add every user-facing string to all three localization files:
  `Resources/en.lproj`, `Resources/uk.lproj`, and `Resources/de.lproj`.
- Keep Bluetooth initialization lazy: normal widget startup must not request
  Bluetooth permission.
- Do not change a physical station while running ordinary tests.

## Testing Local API changes

Run the static checks before opening a pull request:

```sh
./build-app.sh
```

The optional live mode test changes the station's operating mode. Run it only
with an explicit target and an explicit restore mode:

```sh
python3 -u Tests/test_mode_api.py \
  --host <MARSTEK_IP> \
  --restore Manual \
  --live
```

Do not run this command against someone else's station or without permission.

## Pull requests

1. Create a branch from the current `main`.
2. Make the smallest coherent change and update tests or documentation.
3. Run `git diff --check` and the relevant validation commands.
4. Open a pull request using the provided template.
5. Wait for maintainer approval before the protected PR build runs.

The `main` branch is protected. Do not force-push or rewrite published history.
