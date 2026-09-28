# Gattini Homebrew tap

This tap provides [Gattini](https://github.com/sirnax/gattini) 0.2.0 for **Apple Silicon macOS**. Gattini is a local command-line client and daemon for durable AI coding jobs. This is a Homebrew **formula**, not a cask or a graphical Mac app.

## Install

```sh
brew install --formula sirnax/gattini/gattini
```

Homebrew automatically adds this tap when installing the qualified formula. The formula depends on `node@24` and checks the release archive against SHA-256 `97ab34442ff72130333945ff177ff82a82c78a469da050ff1f818d0cc027e06f`. It does not install a model provider, sign you in, or start a background service. If Homebrew asks you to trust the formula, review this repository and trust only `sirnax/gattini/gattini`.

To try an offline fake job, start the daemon in one terminal:

```sh
gattinid
```

Then in another terminal, create a task file and run:

```sh
printf 'Offline smoke test\n' > /tmp/gattini-task.txt
gattini run --role code --task-file /tmp/gattini-task.txt --idempotency-key my-first-test --json
```

The default `code` role uses a fake adapter. It does not call a paid provider. The legacy direct-edit path is disabled. Runtime configuration and the durable job database belong to the daemon in the user's private state directory.

## Uninstall

```sh
brew uninstall --formula sirnax/gattini/gattini
brew untap sirnax/gattini
```

Uninstalling the formula does **not** delete job history or runtime configuration. Stop a manually started `gattinid` process before uninstalling. Homebrew may retain shared dependencies such as `node@24`.

The release archive and checksum are attached to the [source repository's v0.2.0 release](https://github.com/sirnax/gattini/releases/tag/v0.2.0). The formula's `brew test` runs an offline fake job in a disposable state directory. macOS Intel and Windows are not supported by this formula; Linux uses a separate package path.
