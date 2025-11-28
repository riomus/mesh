#!/usr/bin/env bash
set -euo pipefail

# Compute build name/number from `git describe` and expose them for GitHub Actions.
# Outputs (to $GITHUB_OUTPUT):
# - name: semver tag (e.g., 0.0.1)
# - number: commits since tag (integer, min 1)
# - tag_name: a tag/ref to use for the GitHub Release (e.g., 0.0.1-3-gabc1234)
# - describe: the full `git describe` string (same as tag_name)

SEMVER_MATCH='v[0-9]*\.[0-9]*\.[0-9]'

# Ensure tags are available
git fetch --tags --force >/dev/null 2>&1 || true

# Try to get the nearest semver tag; if none, optionally create 0.0.1 in CI and use it
if BASE_TAG=$(git describe --tags --match "$SEMVER_MATCH" --abbrev=0 2>/dev/null); then
  :
else
  # No semver tag found. If running in GitHub Actions, create base tag 0.0.1 at HEAD and push it.
  if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
    echo "No semver tag found. Creating base tag 0.0.1 at HEAD and pushing..."
    git tag -a v0.0.1 -m "CI: initial base version"
    BASE_TAG="v0.0.1"
  else
    BASE_TAG="v0.0.1"
  fi
fi

# Count commits since BASE_TAG (if BASE_TAG exists) else total commits
if git rev-parse -q --verify "refs/tags/$BASE_TAG" >/dev/null; then
  COMMITS_SINCE=$(git rev-list "${BASE_TAG}..HEAD" --count)
else
  COMMITS_SINCE=$(git rev-list HEAD --count)
fi

# Build number must be an integer; ensure at least 1
if [[ -z "${COMMITS_SINCE}" ]]; then COMMITS_SINCE=0; fi
if [[ "${COMMITS_SINCE}" -lt 1 ]]; then BUILD_NUMBER=1; else BUILD_NUMBER=${COMMITS_SINCE}; fi

# Describe (allowing dirty / exact form); if no tags exist, synthesize
if DESC=$(git describe --tags --match "$SEMVER_MATCH" --always --dirty 2>/dev/null); then
  :
else
  SHORT_SHA=$(git rev-parse --short HEAD)
  DESC="${BASE_TAG}-${COMMITS_SINCE}-g${SHORT_SHA}"
fi

# Emit outputs for GitHub Actions (if available)
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "name=${BASE_TAG}"
    echo "number=${BUILD_NUMBER}"
    echo "tag_name=${DESC}"
    echo "describe=${DESC}"
  } >> "$GITHUB_OUTPUT"
fi

# Print a concise log for local visibility
echo "Computed version: name=${BASE_TAG}, number=${BUILD_NUMBER}, describe=${DESC}"
