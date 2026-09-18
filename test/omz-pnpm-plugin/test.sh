#!/bin/bash

set -euo pipefail

# Auto-generated test: feature alone on a bare image, no oh-my-zsh. The plugin
# must be vendored system-wide and the lifecycle script must be a clean no-op.

source dev-container-features-test-lib

check "plugin vendored" bash -c "test -f /usr/local/share/omz-pnpm-plugin/pnpm/pnpm.plugin.zsh"
check "no .git in vendored plugin" bash -c "! test -d /usr/local/share/omz-pnpm-plugin/pnpm/.git"
check "oncreate is a no-op without oh-my-zsh" bash -c "/usr/local/share/omz-pnpm-plugin/scripts/oncreate.sh | grep -q 'skipping'"

reportResults
