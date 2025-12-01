#!/usr/bin/env bash
set -euo pipefail

# Run integration tests using flutter drive.
# Usage:
#   scripts/run_integration.sh android
#   scripts/run_integration.sh web
#   scripts/run_integration.sh macos

PLATFORM=${1:-}
if [[ -z "$PLATFORM" ]]; then
  echo "Usage: $0 <web|android|macos>"
  exit 1
fi

TARGET="integration_test/functional_test.dart"
DRIVER="test_driver/integration_test.dart"

if [[ "$PLATFORM" == "web" ]]; then
  echo "Running integration test on Web (Chrome) via flutter drive..."
  # Ensure localization files are generated where the app expects them
  echo "Generating localizations (flutter gen-l10n)"
  flutter gen-l10n
  flutter drive -d chrome --driver "$DRIVER" --target "$TARGET"
  exit $?
fi

if [[ "$PLATFORM" == "android" ]]; then
  echo "Running integration test on Android via flutter drive..."
  # Ensure localization files are generated where the app expects them
  echo "Generating localizations (flutter gen-l10n)"
  flutter gen-l10n
  DEVICE_ID=$(flutter devices --machine | grep '"platform":"android"' | head -n1 | sed -E 's/.*"id":"([^"]+)".*/\1/')
  if [[ -z "$DEVICE_ID" ]]; then
    echo "No Android devices found. Start an emulator first."
    exit 2
  fi
  echo "Using device: $DEVICE_ID"
  flutter drive -d "$DEVICE_ID" --driver "$DRIVER" --target "$TARGET"
  exit $?
fi

if [[ "$PLATFORM" == "macos" ]]; then
  echo "Running integration test on macOS desktop via flutter test..."
  # Ensure localization files are generated where the app expects them
  echo "Generating localizations (flutter gen-l10n)"
  flutter gen-l10n
  # Ensure macOS desktop is enabled (no-op if already enabled)
  flutter config --enable-macos-desktop || true
  # Run the Integration Test on macOS device target
  flutter test -d macos "$TARGET"
  exit $?
fi

echo "Unknown platform: $PLATFORM (expected web, android or macos)"
exit 3
