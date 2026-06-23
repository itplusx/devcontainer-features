
# Shared pnpm Store (shared-pnpm-store)

Mounts a shared Docker volume as the pnpm store directory so packages are downloaded once and reused across multiple devcontainers. Points pnpm at the volume via containerEnv — no pnpm invocation, no symlink.

## Example Usage

```json
"features": {
    "ghcr.io/itplusx/devcontainer-features/shared-pnpm-store:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## How it works

This feature shares one pnpm content-addressable store across every devcontainer
on the host, so each package is downloaded and unpacked only once.

It does this with four declarative pieces and **no pnpm invocation**:

- **Named volume** `devcontainer-shared-pnpm-store` mounted at
  `/mnt/shared-pnpm-store`. A named volume (not a workspace bind mount) is shared
  by all containers on the host — that is the entire sharing mechanism.
- **`containerEnv`** relocates the store with
  `NPM_CONFIG_STORE_DIR=/mnt/shared-pnpm-store`. pnpm honors `npm_config_*`-style
  settings, so this is the variable that actually moves the store across pnpm
  versions. `PNPM_CONFIG_STORE_DIR` is set to the same value as forward-looking
  coverage for pnpm's native `PNPM_CONFIG_*` variables (not honored for
  `store-dir` on pnpm 10.x, but harmless).
- **`install.sh`** creates the mount point and gives it to the remote user.
- **`oncreate.sh`** (`onCreateCommand`) re-asserts ownership for the current
  non-root user on every container create.

Because pnpm is never invoked, this feature avoids the `pnpm config set --global`
/ `PNPM_HOME` / PATH / non-interactive-shell problems that `mount-pnpm-store` has
to patch. It is a simpler alternative; the two features are independent.

## Ownership of the shared store

The named volume is mounted over `/mnt/shared-pnpm-store` at runtime, so the
build-time `chown` in `install.sh` only sticks the first time the volume is
created. `oncreate.sh` therefore `sudo chown`s the store to the current user on
every create (skipped when running as `root`).

> [!NOTE]
> If you use the same volume from devcontainers running as **different** users
> at the same time, each container's `onCreateCommand` will chown the store to
> its own user. This is inherent to sharing one store across users. The intended
> use is a single developer with a consistent remote user.

## Ensuring pnpm is installed

This feature does not install pnpm. It only configures where pnpm puts its
store, so it works whether pnpm comes from the base image or another feature.
There is a soft dependency (`installsAfter`) on `ghcr.io/devcontainers/features/node`,
`common-utils`, and `fish`. If pnpm is installed by some other feature, you may
need [`overrideFeatureInstallOrder`](https://containers.dev/implementors/features/#overrideFeatureInstallOrder)
to make sure it runs before this one.

## OS and Architecture Support

Architectures: `amd` and `arm`

OS: `ubuntu`, `debian`

Shells: `bash`, `zsh`, `fish` (the feature sets environment only; it does not
depend on the interactive shell)

## Volume Mount Naming

The volume is named `devcontainer-shared-pnpm-store`. Ensure no other Docker
volume collides with this name. (This is a different volume from
`mount-pnpm-store`'s `global-devcontainer-pnpm-store`, so the two features do
not share a store with each other.)

## Changelog

| Version | Notes           |
| ------- | --------------- |
| 1.0.0   | Initial release |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/itplusx/devcontainer-features/blob/main/src/shared-pnpm-store/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
