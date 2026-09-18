#!/bin/bash

set -euo pipefail

source dev-container-features-test-lib

check "plugin installed in ZSH_CUSTOM" bash -c "test -f \"\$HOME/.oh-my-zsh/custom/plugins/pnpm/pnpm.plugin.zsh\""
check "plugin not activated in .zshrc" bash -c "! grep -qE '^plugins=\(.*\bpnpm\b.*\)' \"\$HOME/.zshrc\""

reportResults
