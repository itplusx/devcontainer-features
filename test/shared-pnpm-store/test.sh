#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# NOTE: auto-generated test — the feature is added with no options and no other
# features, so the `pnpm` CLI is NOT guaranteed to be installed. Only assert
# what holds without pnpm.
#
# https://github.com/devcontainers/cli/blob/main/docs/features/test.md

check "PNPM_CONFIG_STORE_DIR is set" bash -c '[ "$PNPM_CONFIG_STORE_DIR" = "/mnt/shared-pnpm-store" ]'
check "NPM_CONFIG_STORE_DIR is set" bash -c '[ "$NPM_CONFIG_STORE_DIR" = "/mnt/shared-pnpm-store" ]'
check "mount exists" bash -c "test -d /mnt/shared-pnpm-store"
check "store is writable" bash -c "touch /mnt/shared-pnpm-store/.write-test && rm /mnt/shared-pnpm-store/.write-test"

# Report result
reportResults
