#!/usr/bin/env bash

set -euo pipefail

REF="${REF:-v1.0.0}"
ACTIVATE="${ACTIVATE:-true}"
USERNAME=${USERNAME:-${_REMOTE_USER:-}}
USER_HOME=${_REMOTE_USER_HOME:-}
FEATURE_ID="omz-pnpm-plugin"
REPO_URL="https://github.com/itplusx/omz-plugin-pnpm.git"
SHARE_DIR="/usr/local/share/${FEATURE_ID}"
PLUGIN_SRC_DIR="${SHARE_DIR}/pnpm"
LIFECYCLE_SCRIPTS_DIR="${SHARE_DIR}/scripts"

if ! command -v git >/dev/null 2>&1; then
    echo "git not found; installing..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y --no-install-recommends git ca-certificates
    rm -rf /var/lib/apt/lists/*
fi

# Always keep a system-wide copy. oncreate.sh copies it into the user's
# oh-my-zsh at container create time, which also covers the case where
# oh-my-zsh is installed by a feature that runs after this one.
echo "Cloning ${REPO_URL} (${REF}) to ${PLUGIN_SRC_DIR}..."
rm -rf "${PLUGIN_SRC_DIR}"
git clone --quiet --depth=1 --branch "${REF}" "${REPO_URL}" "${PLUGIN_SRC_DIR}"
rm -rf "${PLUGIN_SRC_DIR}/.git"

echo "Installing lifecycle script to ${LIFECYCLE_SCRIPTS_DIR}..."
mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
chmod +x "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
printf 'ACTIVATE=%s\n' "${ACTIVATE}" > "${SHARE_DIR}/config"

# Build-time install into the remote user's oh-my-zsh, if it exists already.
if [[ -z "${USER_HOME}" && -n "${USERNAME}" ]]; then
    USER_HOME=$(getent passwd "${USERNAME}" | cut -d: -f6 || true)
fi
if [[ -n "${USER_HOME}" && -d "${USER_HOME}/.oh-my-zsh" ]]; then
    ACTIVATE="${ACTIVATE}" TARGET_HOME="${USER_HOME}" TARGET_USER="${USERNAME}" \
        bash "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
else
    echo "oh-my-zsh not found under '${USER_HOME:-<unknown>}' at build time; will install on container create."
fi

echo "Finished installing ${FEATURE_ID}"
