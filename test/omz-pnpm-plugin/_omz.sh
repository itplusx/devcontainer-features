#!/bin/bash

set -euo pipefail

# Shared assertions for scenarios that have oh-my-zsh + shared-pnpm-store.
# Not run directly as a scenario.

source dev-container-features-test-lib

echo "User: $(whoami), HOME: $HOME"
grep -n '^plugins=' "$HOME/.zshrc" || true

check "plugin installed in ZSH_CUSTOM" bash -c "test -f \"\$HOME/.oh-my-zsh/custom/plugins/pnpm/pnpm.plugin.zsh\""
check "plugin owned by user" bash -c "test \"\$(stat -c '%U' \"\$HOME/.oh-my-zsh/custom/plugins/pnpm\")\" = \"\$USER\""
check "plugin activated in .zshrc" bash -c "grep -qE '^plugins=\(.*\bpnpm\b.*\)' \"\$HOME/.zshrc\""
check "oncreate is idempotent" bash -c "/usr/local/share/omz-pnpm-plugin/scripts/oncreate.sh && [ \"\$(grep -c '^plugins=' \"\$HOME/.zshrc\")\" = 1 ] && grep -qE '^plugins=\(.*\bpnpm\b.*\)' \"\$HOME/.zshrc\" && ! grep -qE 'pnpm.*pnpm' \"\$HOME/.zshrc\""

# The actual bug: an interactive zsh must keep the feature's PNPM_HOME.
pnpmHome=$(zsh -ic 'echo "$PNPM_HOME"' 2>/dev/null | tail -1)
echo "PNPM_HOME in interactive zsh: '$pnpmHome'"
check "PNPM_HOME survives interactive zsh" bash -c "[ '$pnpmHome' = /usr/local/share/pnpm ]"
check "aliases loaded" bash -c "zsh -ic 'type pa' 2>/dev/null | grep -q 'pnpm add'"
check "pnpm -g bin works in zsh" bash -c "zsh -ic 'pnpm -g bin' 2>/dev/null | tail -1 | grep -q '^/usr/local/share/pnpm/bin$'"

reportResults
