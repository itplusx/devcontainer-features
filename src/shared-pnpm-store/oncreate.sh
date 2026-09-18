#!/usr/bin/env bash

set -euo pipefail

STORE_DIR="/mnt/shared-pnpm-store"
PNPM_HOME_DIR="/usr/local/share/pnpm"

# The shared named volumes are mounted over STORE_DIR and
# PNPM_HOME_DIR/package-manager-store at runtime, so build-time ownership only
# sticks the first time a volume is created. Re-assert ownership for the
# current non-root user on every container create so pnpm can always write to
# them, even if a volume was first created by root or a different user.
if [[ "$(id -u)" != "0" ]]; then
    USERNAME="$(id -un)"
    echo "Setting owner of ${STORE_DIR} and ${PNPM_HOME_DIR} to ${USERNAME}..."
    sudo chown -R "${USERNAME}:${USERNAME}" "${STORE_DIR}" "${PNPM_HOME_DIR}"
else
    echo "Running as root; leaving ${STORE_DIR} and ${PNPM_HOME_DIR} ownership unchanged."
fi
