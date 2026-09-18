#!/bin/bash

set -euo pipefail

# Default assertions, reused by scenarios that have pnpm installed.
# Not run directly as a scenario.

source dev-container-features-test-lib

echo "User: $(whoami)"
echo "pnpm: $(pnpm --version)"
pnpm config list || true

# containerEnv points pnpm at the shared volume
check "PNPM_CONFIG_STORE_DIR" bash -c '[ "$PNPM_CONFIG_STORE_DIR" = "/mnt/shared-pnpm-store" ]'

# pnpm resolves its active store under the shared volume (tolerate version subdir)
storePath=$(pnpm store path)
echo "pnpm store path: '$storePath'"
check "store path under mount" bash -c "case \"$storePath\" in /mnt/shared-pnpm-store*) true ;; *) false ;; esac"

# store is writable and owned by the current user
check "store writable" bash -c "touch /mnt/shared-pnpm-store/.write-test && rm /mnt/shared-pnpm-store/.write-test"
check "store owned by user" bash -c "test \"\$(stat -c '%U' /mnt/shared-pnpm-store)\" = \"\$USER\""

# PNPM_HOME is set, non-empty and owned by the current user
check "PNPM_HOME" bash -c '[ "$PNPM_HOME" = "/usr/local/share/pnpm" ]'
check "PNPM_HOME owned by user" bash -c "test \"\$(stat -c '%U' /usr/local/share/pnpm)\" = \"\$USER\""

# package-manager-store is a mounted volume, writable and owned by the current user
check "package-manager-store mounted" bash -c "grep -q ' /usr/local/share/pnpm/package-manager-store ' /proc/mounts"
check "package-manager-store writable" bash -c "touch /usr/local/share/pnpm/package-manager-store/.write-test && rm /usr/local/share/pnpm/package-manager-store/.write-test"
check "package-manager-store owned by user" bash -c "test \"\$(stat -c '%U' /usr/local/share/pnpm/package-manager-store)\" = \"\$USER\""

# global bin dir is on PATH and pnpm agrees on its location
check "global bin dir on PATH" bash -c 'case ":$PATH:" in *:/usr/local/share/pnpm/bin:*) true ;; *) false ;; esac'
globalBin=$(pnpm -g bin)
echo "pnpm -g bin: '$globalBin'"
check "pnpm -g bin succeeds and matches" bash -c "[ \"$globalBin\" = /usr/local/share/pnpm/bin ]"

reportResults
