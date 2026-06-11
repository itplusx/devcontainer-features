#!/bin/bash

set -e

# tests running as remoteUser=root

source dev-container-features-test-lib

# As root, oncreate.sh intentionally skips the chown, and the shared volume
# keeps whatever ownership a previous (non-root) container gave it — so the
# ownership check from _default.sh does not apply here.
pnpmConfig=$(pnpm config get store-dir)
echo "pnpm config get store-dir: '$pnpmConfig'"
check "config" test "$pnpmConfig" = "$(echo ~)/.pnpm-store"
check "store dir writable" test -w /dc/mounted-pnpm-store

reportResults
