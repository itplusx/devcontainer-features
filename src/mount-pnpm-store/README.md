
# Mount pnpm Store (mount-pnpm-store)

[DEPRECATED — use shared-pnpm-store instead] Sets pnpm store to ~/.pnpm-store and mounts it to a volume to share between multiple devcontainers. Patched fork of joshuanianji/devcontainer-features that works with pnpm >= 9 in non-interactive lifecycle shells.

## Example Usage

```json
"features": {
    "ghcr.io/itplusx/devcontainer-features/mount-pnpm-store:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


> [!WARNING]
> **This feature is deprecated.** Use
> [`shared-pnpm-store`](https://github.com/itplusx/devcontainer-features/tree/main/src/shared-pnpm-store)
> instead. It achieves the same shared-store goal with `containerEnv` only — it
> never invokes pnpm, so it avoids the `PNPM_HOME` / PATH / non-interactive-shell
> patching this feature needs. `mount-pnpm-store` will not receive further
> updates.
>
> **Migration:** replace the feature reference in your `devcontainer.json`:
>
> ```json
> "features": {
>     "ghcr.io/itplusx/devcontainer-features/shared-pnpm-store:1": {}
> }
> ```
>
> The two features use different volume names
> (`global-devcontainer-pnpm-store` vs `devcontainer-shared-pnpm-store`), so the
> first `pnpm install` after switching re-populates the new store from the
> registry. Any `PNPM_HOME`/`PATH` workaround you added in `devcontainer.json`
> for this feature can be removed.

## Origin

This feature is a patched copy of [`joshuanianji/devcontainer-features/mount-pnpm-store`](https://github.com/joshuanianji/devcontainer-features/tree/main/src/mount-pnpm-store) (MIT, Copyright (c) 2023 Joshua Ji), copied at upstream version `1.0.2` (commit `e91be54`).

**The patch:** pnpm hard-fails any `--global` command when its global bin directory is not in `PATH`. The expected directory differs by version: `$PNPM_HOME` for pnpm <= 8, `$PNPM_HOME/bin` for pnpm >= 9 (default `~/.local/share/pnpm[/bin]`). The feature's `onCreateCommand` script runs in a non-interactive shell where rc-file exports are not loaded, so `pnpm config set store-dir --global` killed the container build (see [upstream issue #80](https://github.com/joshuanianji/devcontainer-features/issues/80) and [devcontainers-extra/features#218](https://github.com/devcontainers-extra/features/issues/218)). `oncreate.sh` now exports `PNPM_HOME` (defaulting to `~/.local/share/pnpm`) and prepends both `$PNPM_HOME/bin` and `$PNPM_HOME` to `PATH` before invoking pnpm. The feature is therefore self-sufficient — no `remoteEnv`/`containerEnv` workaround is needed in the consuming `devcontainer.json`, and project-local `pnpm install` works out of the box.

### Global pnpm commands in your own shells

The patch only fixes the environment for this feature's own script. If *you* run pnpm global commands (`pnpm add -g ...`) in container terminals or your own lifecycle scripts, those shells need the same environment. Declare it in your `devcontainer.json` (adjust the home directory to your `remoteUser`):

```json
"containerEnv": {
    "PNPM_HOME": "/home/vscode/.local/share/pnpm"
},
"remoteEnv": {
    "PATH": "/home/vscode/.local/share/pnpm/bin:${containerEnv:PATH}"
}
```

> [!WARNING]
> The `PATH` entry must go in `remoteEnv`, **not** `containerEnv`: the `${containerEnv:VAR}` substitution is only resolved in `remoteEnv`. Putting it in `containerEnv` sets the container's `PATH` to the literal unresolved string, which breaks every binary lookup (`sleep`, `sed`, ...) and makes the container exit immediately after start.

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
| 1.2.0   | Deprecated in favor of `shared-pnpm-store`                                          |
| 1.1.0   | Copy to itplusx namespace; fix `oncreate.sh` for the pnpm global bin dir check     |
| 1.0.2   | (upstream) Move onCreate lifecycle script to `oncreate.sh`                         |
| 1.0.1   | (upstream) Fix Docs                                                                |
| 1.0.0   | (upstream) Support zsh + refactor                                                  |

## References

- [Upstream feature by Joshua Ji](https://github.com/joshuanianji/devcontainer-features/tree/main/src/mount-pnpm-store)
- [Pnpm Devcontainer Setup by PatrickChoDev](https://gist.github.com/PatrickChoDev/81d36159aca4dc687b8c89983e64da2e)


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/itplusx/devcontainer-features/blob/main/src/mount-pnpm-store/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
