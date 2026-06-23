#!/bin/bash

set -euo pipefail

source dev-container-features-test-lib

# As root, oncreate.sh intentionally skips the chown, so the store is not
# user-owned. Assert pnpm still resolves into the mount and it is writable.
storePath=$(pnpm store path)
echo "pnpm store path: '$storePath'"
check "store path under mount" bash -c "case \"$storePath\" in /mnt/shared-pnpm-store*) true ;; *) false ;; esac"
check "store writable" bash -c "touch /mnt/shared-pnpm-store/.write-test && rm /mnt/shared-pnpm-store/.write-test"

reportResults
