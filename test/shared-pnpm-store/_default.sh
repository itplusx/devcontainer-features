#!/bin/bash

set -e

# Default assertions, reused by scenarios that have pnpm installed.
# Not run directly as a scenario.

source dev-container-features-test-lib

echo "User: $(whoami)"
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

reportResults
