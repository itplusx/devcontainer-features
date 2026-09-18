#!/bin/bash

set -euo pipefail

# Optional: Import test library
source dev-container-features-test-lib

# NOTE: auto-generated test — the feature is added with no options and no other
# features, so the `pnpm` CLI is NOT guaranteed to be installed. Only assert
# what holds without pnpm.
#
# https://github.com/devcontainers/cli/blob/main/docs/features/test.md

check "PNPM_CONFIG_STORE_DIR is set" bash -c '[ "$PNPM_CONFIG_STORE_DIR" = "/mnt/shared-pnpm-store" ]'
check "NPM_CONFIG_STORE_DIR is set" bash -c '[ "$NPM_CONFIG_STORE_DIR" = "/mnt/shared-pnpm-store" ]'
check "PNPM_HOME is set" bash -c '[ "$PNPM_HOME" = "/usr/local/share/pnpm" ]'
check "global bin dir on PATH" bash -c 'case ":$PATH:" in *:/usr/local/share/pnpm/bin:*) true ;; *) false ;; esac'
check "mount exists" bash -c "test -d /mnt/shared-pnpm-store"
check "store is writable" bash -c "touch /mnt/shared-pnpm-store/.write-test && rm /mnt/shared-pnpm-store/.write-test"
check "package-manager-store mount exists" bash -c "test -d /usr/local/share/pnpm/package-manager-store"
check "package-manager-store is writable" bash -c "touch /usr/local/share/pnpm/package-manager-store/.write-test && rm /usr/local/share/pnpm/package-manager-store/.write-test"

# Report result
reportResults
