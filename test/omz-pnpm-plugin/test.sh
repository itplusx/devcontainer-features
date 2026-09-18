#!/bin/bash

set -euo pipefail

# Auto-generated test: feature alone on a base image. Bare images (debian,
# ubuntu) have no oh-my-zsh, the devcontainers base images ship it for the
# remote user. The plugin must be vendored system-wide either way; the
# lifecycle script installs into oh-my-zsh when present and is a clean no-op
# otherwise.

source dev-container-features-test-lib

check "plugin vendored" bash -c "test -f /usr/local/share/omz-pnpm-plugin/pnpm/pnpm.plugin.zsh"
check "no .git in vendored plugin" bash -c "! test -d /usr/local/share/omz-pnpm-plugin/pnpm/.git"

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh present for $(whoami)"
    check "plugin installed in ZSH_CUSTOM" bash -c "test -f \"\$HOME/.oh-my-zsh/custom/plugins/pnpm/pnpm.plugin.zsh\""
    check "plugin activated in .zshrc" bash -c "grep -qE '^plugins=\(.*\bpnpm\b.*\)' \"\$HOME/.zshrc\""
    check "oncreate is idempotent" bash -c "/usr/local/share/omz-pnpm-plugin/scripts/oncreate.sh | grep -q 'already'"
else
    echo "no oh-my-zsh for $(whoami)"
    check "oncreate is a no-op without oh-my-zsh" bash -c "/usr/local/share/omz-pnpm-plugin/scripts/oncreate.sh | grep -q 'skipping'"
fi

reportResults
