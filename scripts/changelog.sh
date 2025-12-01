#!/usr/bin/env bash
set -euo pipefail

# Generate CHANGELOG_RELEASE.md from git commits since the last tag.
# If no tags exist, include the full history.

OUT_FILE="CHANGELOG_RELEASE.md"

# Ensure we are in repo root
if [[ ! -d .git ]]; then
  echo "Run this script from the repository root" >&2
  exit 1
fi

LAST_TAG=""
if git describe --tags --abbrev=0 >/dev/null 2>&1; then
  LAST_TAG=$(git describe --tags --abbrev=0)
fi

NEW_TAG=${NEW_TAG:-}
DESCRIBE=${DESCRIBE:-}

{
  echo "# Release ${NEW_TAG:-unversioned}"
  if [[ -n "$DESCRIBE" ]]; then
    echo
    echo "Version (git describe): $DESCRIBE"
  fi

  echo
  if [[ -n "$LAST_TAG" ]]; then
    echo "Changes since $LAST_TAG:"
    echo
    git log "${LAST_TAG}..HEAD" --pretty='* %s (%h) — %an' --no-merges || true
  else
    echo "Changes in initial release:"
    echo
    git log --pretty='* %s (%h) — %an' --no-merges || true
  fi

  echo
  echo "Artifacts:"
  echo "- Web ZIP"
  echo "- Android APK & AAB"
  echo "- iOS IPA (unsigned)"
  echo "- macOS app (.app zipped, unsigned)"
} > "$OUT_FILE"

echo "Generated $OUT_FILE"
