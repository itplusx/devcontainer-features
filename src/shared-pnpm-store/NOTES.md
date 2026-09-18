## How it works

This feature shares one pnpm content-addressable store across every devcontainer
on the host, so each package is downloaded and unpacked only once. Since 1.1.0 it
also owns `PNPM_HOME`, so pnpm's self-managed versions are shared as well and
pnpm never falls back to the current directory.

It does this with declarative pieces and **no pnpm invocation**:

- **Named volume** `devcontainer-shared-pnpm-store` mounted at
  `/mnt/shared-pnpm-store`. A named volume (not a workspace bind mount) is shared
  by all containers on the host — that is the entire sharing mechanism.
- **Named volume** `devcontainer-shared-pnpm-package-manager-store` mounted at
  `/usr/local/share/pnpm/package-manager-store`. This is where pnpm caches the
  pnpm versions it downloads when a project's `packageManager` field differs
  from the installed pnpm (`manage-package-manager-versions`, on by default since
  pnpm 10). Shared across containers, so each pnpm version is downloaded once.
- **`containerEnv`**
  - `NPM_CONFIG_STORE_DIR=/mnt/shared-pnpm-store` relocates the store. pnpm
    honors `npm_config_*`-style settings, so this is the variable that actually
    moves the store across pnpm versions. `PNPM_CONFIG_STORE_DIR` is set to the
    same value as forward-looking coverage for pnpm's native `PNPM_CONFIG_*`
    variables (not honored for `store-dir` on pnpm 10.x, but harmless).
  - `PNPM_HOME=/usr/local/share/pnpm` is pnpm's home for global packages
    (`global/`), the global bin dir (`bin/`) and the package-manager store.
  - `NPM_CONFIG_GLOBAL_BIN_DIR=/usr/local/share/pnpm/bin` (and the
    `PNPM_CONFIG_*` twin) pins the global bin dir explicitly. pnpm 11+ defaults
    to `$PNPM_HOME/bin`, pnpm 10 to `$PNPM_HOME` itself; the explicit setting
    makes the layout identical across versions.
  - `PATH` gets `/usr/local/share/pnpm/bin` prepended so `pnpm add -g` works and
    `pnpm -g bin` no longer fails with `ERR_PNPM_GLOBAL_BIN_DIR_NOT_IN_PATH`.
- **`install.sh`** creates the mount points and `PNPM_HOME` tree and gives them
  to the remote user.
- **`oncreate.sh`** (`onCreateCommand`) re-asserts ownership for the current
  non-root user on every container create.

Because pnpm is never invoked, this feature avoids the `pnpm config set --global`
/ non-interactive-shell problems that arise when a feature has to configure pnpm
from a non-interactive lifecycle shell.

## Why `PNPM_HOME` matters

If `PNPM_HOME` is unset, pnpm falls back to `~/.local/share/pnpm`, which is
per container: every container downloads the same pnpm versions again (about
300 MB each). If `PNPM_HOME` is set but **empty** — which the original
`ntnyq/omz-plugin-pnpm` oh-my-zsh plugin does when `pnpm -g bin` fails — pnpm
treats the current working directory as its home and litters `global/` and
`package-manager-store/` into whatever project you run it from. Setting
`PNPM_HOME` at the image level rules out both.

If you use oh-my-zsh with a pnpm plugin, use
[`omz-pnpm-plugin`](../omz-pnpm-plugin) from this repository. It installs the
[itplusx fork](https://github.com/itplusx/omz-plugin-pnpm) of the plugin, which
respects a pre-set `PNPM_HOME`. The original plugin overrides `PNPM_HOME` with
the bin dir on every interactive shell start, which on pnpm 11+ moves the
package-manager store out of the shared volume.

## Ownership of the shared volumes

The named volumes are mounted at runtime, so the build-time `chown` in
`install.sh` only sticks the first time a volume is created. `oncreate.sh`
therefore `sudo chown`s both the store and `PNPM_HOME` to the current user on
every create (skipped when running as `root`).

> [!NOTE]
> If you use the same volumes from devcontainers running as **different** users
> at the same time, each container's `onCreateCommand` will chown them to
> its own user. This is inherent to sharing across users. The intended
> use is a single developer with a consistent remote user.

## Ensuring pnpm is installed

This feature does not install pnpm. It only configures where pnpm puts its
data, so it works whether pnpm comes from the base image or another feature.
There is a soft dependency (`installsAfter`) on `ghcr.io/devcontainers/features/node`,
`common-utils`, and `fish`. If pnpm is installed by some other feature, you may
need [`overrideFeatureInstallOrder`](https://containers.dev/implementors/features/#overrideFeatureInstallOrder)
to make sure it runs before this one.

You do **not** need to pin `pnpmVersion` on the node feature to match your
project's `packageManager`. pnpm switches versions on its own, and with the
shared package-manager store that is a one-time download per version.

## OS and Architecture Support

Architectures: `amd` and `arm`

OS: `ubuntu`, `debian`

Shells: `bash`, `zsh`, `fish` (the feature sets environment only; it does not
depend on the interactive shell)

pnpm: 10, 11, 12 (`NPM_CONFIG_GLOBAL_BIN_DIR` is honored by all three)

## Volume Mount Naming

The volumes are named `devcontainer-shared-pnpm-store` and
`devcontainer-shared-pnpm-package-manager-store`. Ensure no other Docker
volumes collide with these names.

## Changelog

| Version | Notes |
| ------- | ----- |
| 1.1.0   | Set `PNPM_HOME=/usr/local/share/pnpm`, pin the global bin dir to `$PNPM_HOME/bin` and put it on `PATH`. Share `package-manager-store` via a second named volume. Global packages installed before 1.1.0 lived under `~/.local/share/pnpm` and must be reinstalled with `pnpm add -g`. |
| 1.0.1   | Bash best practices across scripts |
| 1.0.0   | Initial release |
