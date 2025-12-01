#!/usr/bin/env bash
set -euo pipefail

# Generate CHANGELOG_RELEASE.md from git commits since the last semantic version tag.
# If no semver tags exist, include the full history.

OUT_FILE="CHANGELOG_RELEASE.md"

# Ensure we are in repo root
if [[ ! -d .git ]]; then
  echo "Run this script from the repository root" >&2
  exit 1
fi

# Make sure tags are available (useful in CI)
git fetch --tags --force >/dev/null 2>&1 || true

# Resolve the last semantic version tag only (avoid describe-like tags such as v1.2.3-45-gabcd123)
LAST_TAG=""
if git describe --tags --abbrev=0 >/dev/null 2>&1; then
  LAST_TAG=$(git describe --tags --abbrev=0)
fi

NEW_TAG=${NEW_TAG:-}
DESCRIBE=${DESCRIBE:-}

# Helper to print a changelog section for a given git range.
# Prefers non-merge commits, but falls back to including merges if that would be empty.
print_changelog_for_range() {
  local range="$1"
  local fmt='* %s (%h) — %an'

  # Try without merges first (cleaner list)
  local log_output
  if ! log_output=$(git log "$range" --pretty="$fmt" --no-merges 2>/dev/null); then
    log_output=""
  fi

  # If empty, include merges as well (common when all changes are PR merge commits)
  if [[ -z "${log_output//[[:space:]]/}" ]]; then
    if ! log_output=$(git log "$range" --pretty="$fmt" 2>/dev/null); then
      log_output=""
    fi
  fi

  if [[ -n "${log_output//[[:space:]]/}" ]]; then
    # Convert literal \n sequences inside commit subjects into real newlines
    # and indent continuation lines so Markdown renders them under the same list item.
    # Example:
    #   * feat: something with details\n\n- point 1\n- point 2 (abcd123) — User
    # becomes:
    #   * feat: something with details
    #     
    #     - point 1
    #     - point 2 (abcd123) — User
    formatted=$(printf '%b' "$log_output" | awk '
      /^\* / { print; next }
      /^$/ { print; next }
      { print "  " $0 }
    ')
    echo "$formatted"
  else
    echo "* No commits found in range $range"
  fi
}

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
    print_changelog_for_range "${LAST_TAG}..HEAD"
  else
    echo "Changes in initial release:"
    echo
    print_changelog_for_range "HEAD"
  fi

  echo
  echo "Artifacts:"
  echo "- Web ZIP"
  echo "- Android APK & AAB"
  echo "- iOS IPA (unsigned)"
  echo "- macOS app (.app zipped, unsigned)"
} > "$OUT_FILE"

echo "Generated $OUT_FILE"
