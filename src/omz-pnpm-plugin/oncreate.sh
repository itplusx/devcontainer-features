#!/usr/bin/env bash

set -euo pipefail

# Copies the vendored plugin into the current user's oh-my-zsh custom plugins
# and activates it in ~/.zshrc. Runs at build time (from install.sh, as root,
# with TARGET_HOME/TARGET_USER set) and on every container create (as the
# remote user). Idempotent.

SHARE_DIR="/usr/local/share/omz-pnpm-plugin"
PLUGIN_SRC_DIR="${SHARE_DIR}/pnpm"
TARGET_HOME="${TARGET_HOME:-$HOME}"
TARGET_USER="${TARGET_USER:-$(id -un)}"

if [[ -z "${ACTIVATE:-}" && -f "${SHARE_DIR}/config" ]]; then
    # shellcheck disable=SC1091
    source "${SHARE_DIR}/config"
fi
ACTIVATE="${ACTIVATE:-true}"

if [[ ! -d "${TARGET_HOME}/.oh-my-zsh" ]]; then
    echo "oh-my-zsh not found under ${TARGET_HOME}; skipping pnpm plugin install."
    exit 0
fi

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${TARGET_HOME}/.oh-my-zsh/custom}"
PLUGIN_DIR="${ZSH_CUSTOM_DIR}/plugins/pnpm"

if [[ ! -f "${PLUGIN_DIR}/pnpm.plugin.zsh" ]] || ! cmp -s "${PLUGIN_SRC_DIR}/pnpm.plugin.zsh" "${PLUGIN_DIR}/pnpm.plugin.zsh"; then
    echo "Installing pnpm plugin to ${PLUGIN_DIR}..."
    rm -rf "${PLUGIN_DIR}"
    mkdir -p "${ZSH_CUSTOM_DIR}/plugins"
    cp -r "${PLUGIN_SRC_DIR}" "${PLUGIN_DIR}"
    if [[ "$(id -u)" == "0" && "${TARGET_USER}" != "root" ]]; then
        chown -R "${TARGET_USER}:${TARGET_USER}" "${PLUGIN_DIR}"
    fi
else
    echo "pnpm plugin already up to date in ${PLUGIN_DIR}."
fi

ZSHRC="${TARGET_HOME}/.zshrc"
if [[ "${ACTIVATE}" == "true" && -f "${ZSHRC}" ]]; then
    if grep -qE '^plugins=\(([^)]*[[:space:]])?pnpm([[:space:]][^)]*)?\)' "${ZSHRC}"; then
        echo "pnpm plugin already activated in ${ZSHRC}."
    elif grep -qE '^plugins=\(' "${ZSHRC}"; then
        echo "Activating pnpm plugin in ${ZSHRC}..."
        sed -i -E 's/^plugins=\(([^)]*)\)/plugins=(\1 pnpm)/; s/plugins=\( pnpm\)/plugins=(pnpm)/' "${ZSHRC}"
    else
        echo "Activating pnpm plugin in ${ZSHRC} (new plugins line)..."
        printf '\nplugins=(pnpm)\n' >> "${ZSHRC}"
    fi
fi
