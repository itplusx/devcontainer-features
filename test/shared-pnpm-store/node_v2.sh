#!/bin/bash

set -e

# node feature v2 installs latest pnpm by default; this feature touches no
# pnpm global state, so the default assertions are sufficient.
./_default.sh
