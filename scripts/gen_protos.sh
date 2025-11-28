#!/usr/bin/env bash
set -euo pipefail

# Generate Dart protobufs from the meshtastic submodule using buf.
# Output goes to lib/generated/meshtastic and is git-ignored.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

if ! command -v buf >/dev/null 2>&1; then
  echo "Error: buf is not installed or not on PATH." >&2
  echo "Install buf from https://buf.build/docs/installation or use CI which installs it automatically." >&2
  exit 1
fi

# Ensure protoc-gen-dart is available for the buf 'dart' plugin.
if ! command -v protoc-gen-dart >/dev/null 2>&1; then
  echo "Installing protoc_plugin to provide protoc-gen-dart..."
  dart pub global activate protoc_plugin >/dev/null
  export PATH="$PATH:${HOME}/.pub-cache/bin"
fi

# Create output dir to avoid analyzer warnings before first gen
mkdir -p lib/generated/meshtastic

echo "Generating Dart protobufs with buf..."
BUF_TEMPLATE="buf.gen.yaml"
MODULE_DIR="mesh/meshtastic"

if [ ! -f "$BUF_TEMPLATE" ]; then
  echo "Error: $BUF_TEMPLATE not found in repo root." >&2
  exit 1
fi
if [ ! -d "$MODULE_DIR" ]; then
  echo "Error: $MODULE_DIR not found. Make sure git submodules are initialized (git submodule update --init --recursive)." >&2
  exit 1
fi

      buf generate --template "$BUF_TEMPLATE"

echo "Protobuf generation complete. Output in lib/generated/meshtastic"
