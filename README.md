# mesh

A new Flutter project.

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

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
