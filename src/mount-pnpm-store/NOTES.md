## Origin

This feature is a patched copy of [`joshuanianji/devcontainer-features/mount-pnpm-store`](https://github.com/joshuanianji/devcontainer-features/tree/main/src/mount-pnpm-store) (MIT, Copyright (c) 2023 Joshua Ji), copied at upstream version `1.0.2` (commit `e91be54`).

**The patch:** pnpm >= 9 hard-fails any `--global` command when its global bin directory (`$PNPM_HOME/bin`, default `~/.local/share/pnpm/bin`) is not in `PATH`. The feature's `onCreateCommand` script runs in a non-interactive shell where rc-file exports are not loaded, so `pnpm config set store-dir --global` killed the container build (see [upstream issue #80](https://github.com/joshuanianji/devcontainer-features/issues/80) and [devcontainers-extra/features#218](https://github.com/devcontainers-extra/features/issues/218)). `oncreate.sh` now exports `PNPM_HOME` (defaulting to `~/.local/share/pnpm`) and prepends `$PNPM_HOME/bin` to `PATH` before invoking pnpm, so no `remoteEnv`/`containerEnv` workaround is needed in the consuming `devcontainer.json` for the feature itself to install.

Note: your *own* lifecycle scripts or non-interactive shells that run `pnpm` global commands still need the same environment. Declare it once in your `devcontainer.json` (adjust the home directory to your `remoteUser`):

```json
"containerEnv": {
    "PNPM_HOME": "/home/vscode/.local/share/pnpm",
    "PATH": "/home/vscode/.local/share/pnpm/bin:${containerEnv:PATH}"
}
```

## OS and Architecture Support

Architectures: `amd` and `arm`

OS: `ubuntu`, `debian`

Shells: `bash`, `zsh`, `fish`

## Important Implementation Details

### pnpm `store-dir`

This is opinionated, but having the pnpm store in the workspace along with your code adds clutter. This feature sets the pnpm `store-dir` config to `~/.pnpm-store`, so it's out of sight. The home directory will be based on the `remoteUser` of the base image you have.

### Ensuring pnpm is installed

This feature does not install pnpm by itself and expects `pnpm` to be installed already, either by a base image or by a feature. If pnpm is not installed, it just gives a warning (you'll have a random ~/.pnpm-store folder in your home directory and the pnpm `store-dir` config will not be set) but does not fail.

If you are installing pnpm with a feature, you may need to ensure it is run **before** `mount-pnpm-store`. There is a soft dependency on `ghcr.io/devcontainers/features/node` already, but if it is any other feature that installs pnpm you might need to put some extra work.

To make this work, use the [`overrideFeatureInstallOrder` property](https://containers.dev/implementors/features/#overrideFeatureInstallOrder), since the default feature installation order is based on ID. Here is an example using a fake `unknown-install-pnpm`:

```json
    "image": "mcr.microsoft.com/devcontainers/base:bullseye",
    "features": {
        "ghcr.io/random-user/devcontainer-features/unknown-install-pnpm:1": {},
        "ghcr.io/itplusx/devcontainer-features/mount-pnpm-store:1": {}
    },
    "overrideFeatureInstallOrder": [
        "ghcr.io/random-user/devcontainer-features/unknown-install-pnpm",
        "ghcr.io/itplusx/devcontainer-features/mount-pnpm-store"
    ]
```

### Volume Mount Naming

The volume mount is called `global-devcontainer-pnpm-store` (same name as upstream, so the store is shared with containers using the upstream feature). Ensure that no other docker volumes match this name.

## Changelog

| Version | Notes                                                                              |
| ------- | ---------------------------------------------------------------------------------- |
| 1.1.0   | Copy to itplusx namespace; fix `oncreate.sh` for pnpm >= 9 global bin dir check    |
| 1.0.2   | (upstream) Move onCreate lifecycle script to `oncreate.sh`                         |
| 1.0.1   | (upstream) Fix Docs                                                                |
| 1.0.0   | (upstream) Support zsh + refactor                                                  |

## References

- [Upstream feature by Joshua Ji](https://github.com/joshuanianji/devcontainer-features/tree/main/src/mount-pnpm-store)
- [Pnpm Devcontainer Setup by PatrickChoDev](https://gist.github.com/PatrickChoDev/81d36159aca4dc687b8c89983e64da2e)
