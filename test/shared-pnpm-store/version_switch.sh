#!/bin/bash

set -euo pipefail

# Reproduction of the original bug:
# a project pins a pnpm version that differs from the installed one. pnpm then
# downloads the pinned version into "$PNPM_HOME/package-manager-store". With an
# empty PNPM_HOME that ended up in the project root.

source dev-container-features-test-lib

./_default.sh

installed=$(pnpm --version)
pinned="12.3.4"
if [ "$installed" = "$pinned" ]; then pinned="12.3.3"; fi
echo "installed pnpm: $installed, pinning: $pinned"

project=$(mktemp -d "$HOME/version-switch.XXXXXX")
cd "$project"
printf '{ "name": "version-switch", "private": true, "packageManager": "pnpm@%s" }\n' "$pinned" > package.json

# simulate the broken plugin state on top of the feature's env: an interactive
# zsh with the original omz plugin would have exported PNPM_HOME="" here.
switched=$(pnpm --version)
echo "pnpm --version inside project: $switched"
check "pnpm switched to pinned version" bash -c "[ '$switched' = '$pinned' ]"
check "no package-manager-store in project root" bash -c "! test -e '$project/package-manager-store'"
check "no global dir in project root" bash -c "! test -e '$project/global'"
check "no package-manager-store in per-user dir" bash -c "! test -e '$HOME/.local/share/pnpm/package-manager-store'"
check "pinned version cached in shared volume" bash -c "find /usr/local/share/pnpm/package-manager-store -path '*pnpm*$pinned*' | grep -q ."

reportResults
