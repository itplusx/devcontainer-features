#!/usr/bin/env bash

set -euo pipefail

USERNAME=${USERNAME:-${_REMOTE_USER:-}}
FEATURE_ID="shared-pnpm-store"
STORE_DIR="/mnt/shared-pnpm-store"
PNPM_HOME_DIR="/usr/local/share/pnpm"
LIFECYCLE_SCRIPTS_DIR="/usr/local/share/${FEATURE_ID}/scripts"

echo "Ensuring pnpm store directory ${STORE_DIR} exists..."
mkdir -p "${STORE_DIR}"

# PNPM_HOME holds the global bin dir (bin/), global packages (global/) and the
# cache of self-managed pnpm versions (package-manager-store/, mounted as a
# shared volume at runtime). Pre-create the tree so the mount point exists.
echo "Ensuring PNPM_HOME ${PNPM_HOME_DIR} exists..."
mkdir -p "${PNPM_HOME_DIR}/bin" "${PNPM_HOME_DIR}/package-manager-store"

if [[ -n "${USERNAME}" && "${USERNAME}" != "root" ]]; then
    echo "Setting owner of ${STORE_DIR} and ${PNPM_HOME_DIR} to ${USERNAME}..."
    chown -R "${USERNAME}:${USERNAME}" "${STORE_DIR}" "${PNPM_HOME_DIR}"
else
    echo "No non-root user; leaving ${STORE_DIR} and ${PNPM_HOME_DIR} owned by root."
fi

# Install lifecycle script (re-asserts ownership at container create time)
if [[ -f oncreate.sh ]]; then
    echo "Installing oncreate.sh to ${LIFECYCLE_SCRIPTS_DIR}..."
    mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
    cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
    chmod +x "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
fi

echo "Finished installing ${FEATURE_ID}"
