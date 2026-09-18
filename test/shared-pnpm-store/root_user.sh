#!/bin/bash

set -euo pipefail

source dev-container-features-test-lib

# As root, oncreate.sh intentionally skips the chown, so the dirs are not
# user-owned. Assert pnpm still resolves into the mounts and they are writable.
storePath=$(pnpm store path)
echo "pnpm store path: '$storePath'"
check "store path under mount" bash -c "case \"$storePath\" in /mnt/shared-pnpm-store*) true ;; *) false ;; esac"
check "store writable" bash -c "touch /mnt/shared-pnpm-store/.write-test && rm /mnt/shared-pnpm-store/.write-test"
check "PNPM_HOME" bash -c '[ "$PNPM_HOME" = "/usr/local/share/pnpm" ]'
check "package-manager-store writable" bash -c "touch /usr/local/share/pnpm/package-manager-store/.write-test && rm /usr/local/share/pnpm/package-manager-store/.write-test"
check "pnpm -g bin succeeds" bash -c "pnpm -g bin"

reportResults
