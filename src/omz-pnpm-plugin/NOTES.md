## How it works

- **`install.sh`** clones the [itplusx fork of
  omz-plugin-pnpm](https://github.com/itplusx/omz-plugin-pnpm) at the given
  `ref` into `/usr/local/share/omz-pnpm-plugin/pnpm` (system-wide, no `.git`).
  If the remote user already has oh-my-zsh at build time, it installs the plugin
  right away.
- **`oncreate.sh`** (`onCreateCommand`) copies the plugin into
  `${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/pnpm` and, with `activate: true`,
  appends `pnpm` to the `plugins=(...)` line of `~/.zshrc` if missing. It is
  idempotent and also covers oh-my-zsh being installed by a feature that runs
  after this one. If oh-my-zsh is not present, it does nothing.

## Why a fork

The original [ntnyq/omz-plugin-pnpm](https://github.com/ntnyq/omz-plugin-pnpm)
is unmaintained and mishandles `PNPM_HOME`:

- when `pnpm -g bin` fails (fresh container, bin dir not on `PATH`) it still
  runs `export PNPM_HOME=""`, and pnpm treats an empty `PNPM_HOME` as the
  current directory. Every pnpm call then creates `global/` and
  `package-manager-store/` in your project root.
- when `pnpm -g bin` succeeds it overrides `PNPM_HOME` with the bin dir. On
  pnpm 11+ that is `$PNPM_HOME/bin`, which moves the package-manager store out
  of the volume that [`shared-pnpm-store`](../shared-pnpm-store) mounts.

The fork leaves a pre-set `PNPM_HOME` alone and never exports an empty one.
Aliases are unchanged.

## Pairing with `shared-pnpm-store`

Use both features together. `shared-pnpm-store` sets `PNPM_HOME` and the
global bin dir at the image level, this feature makes sure the interactive zsh
does not undo that.

```json
"features": {
    "ghcr.io/nils-geistmann/devcontainers-features/zsh:0.0.8": {
        "plugins": "git docker"
    },
    "ghcr.io/itplusx/devcontainer-features/shared-pnpm-store:1.1.0": {},
    "ghcr.io/itplusx/devcontainer-features/omz-pnpm-plugin:1.0.0": {}
}
```

Listing `pnpm` in the zsh feature's `plugins` option is optional; with
`activate: true` this feature adds it.

## OS and Architecture Support

Architectures: `amd` and `arm`

OS: `ubuntu`, `debian`

Requires `git` at build time (installed via apt if missing) and oh-my-zsh for
the remote user (from `common-utils`, `nils-geistmann/zsh` or any other
source). Without oh-my-zsh the feature installs cleanly and does nothing.

## Changelog

| Version | Notes           |
| ------- | --------------- |
| 1.0.0   | Initial release |
