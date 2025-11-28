# mesh

🚧 UNDER CONSTRUCTION 🚧

This repository is an active work‑in‑progress. Interfaces, features, and docs may change rapidly. Expect breaking changes until the first public release.

## What is this?

Multi‑platform, multi‑mesh controlling app aiming to support:
- Meshtastic (including FW+ versions)
- MeshCore

Targets: Web, Android, iOS, macOS, Windows, and Linux (where supported by Flutter and platform capabilities like Bluetooth/Web Bluetooth).

## CI: Build & Release on main

This repo includes a GitHub Actions workflow that builds and publishes releases for Web, Android, and iOS on every push to the `main` branch.

Artifacts attached to each GitHub Release:
- Web: zipped `build/web`
- Android: `app-release.apk` and `app-release.aab`
- iOS: unsigned `.ipa` (no codesign)

### Versioning
- The workflow uses `git describe` for versioning.
- A semantic base tag (e.g., `0.0.1`) is used as the app `--build-name`.
- The Android/iOS `--build-number` is computed as commits since the base tag.
- On the first run, if no semantic tags exist, the workflow will create and push a tag `0.0.1` at the current commit.

To create the base tag manually instead, run:
```
git tag -a 0.0.1 -m "Initial base version"
git push origin 0.0.1
```

### Running locally
1) `flutter pub get`
2) Run on target platform(s):
   - Web: `flutter run -d chrome` (HTTPS in production)
   - Android: `flutter run -d android`
   - iOS: `flutter run -d ios`

Notes:
- Web Bluetooth requires HTTPS (or `localhost`) and a user gesture (tap Scan).
- Android 12+: asks for `BLUETOOTH_SCAN/CONNECT` at runtime. Older Android: location permission.
- iOS: Bluetooth permission prompt on first use.

## Project status

- Current state: pre‑alpha, rapid development.
- Expect frequent force‑pushes, API/UX churn, and incomplete features.
- Issues and PRs are welcome, but please understand the pace and volatility.

## Getting Started (for contributors)

This is a standard Flutter workspace. If you are setting up your environment:

- [Flutter installation guide](https://docs.flutter.dev/get-started/install)
- [Flutter codelab](https://docs.flutter.dev/get-started/codelab)
- [Flutter cookbook](https://docs.flutter.dev/cookbook)

Once Flutter is installed, see the Running locally section above.
