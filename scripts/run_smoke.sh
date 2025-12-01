#!/usr/bin/env bash
set -euo pipefail

# Simple runner for the integration_test/smoke_test.dart on selected platform.
# Usage:
#   scripts/run_smoke.sh web
#   scripts/run_smoke.sh android

PLATFORM=${1:-}
if [[ -z "$PLATFORM" ]]; then
  echo "Usage: $0 <web|android>"
  exit 1
fi

if [[ "$PLATFORM" == "web" ]]; then
  echo "Running smoke test on Web (Chrome) using widget tests..."
  # Run a minimal widget smoke test in Chrome to validate the app renders.
  flutter test --platform chrome test/widget_test.dart
  exit $?
fi

if [[ "$PLATFORM" == "android" ]]; then
  echo "Running smoke test on Android (first available emulator/device)..."
  # Pick the first attached Android device
  DEVICE_ID=$(flutter devices --machine | grep '"platform":"android"' | head -n1 | sed -E 's/.*"id":"([^"]+)".*/\1/')
  if [[ -z "$DEVICE_ID" ]]; then
    echo "No Android devices found. Start an emulator first (e.g., Pixel API)."
    exit 2
  fi
  echo "Using device: $DEVICE_ID"
  flutter test -d "$DEVICE_ID" integration_test
  exit $?
fi

echo "Unknown platform: $PLATFORM (expected web or android)"
exit 3
