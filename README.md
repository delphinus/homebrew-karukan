# homebrew-karukan

A Homebrew tap for `karukan-server`, the HTTP server of [karukan](https://github.com/togatoga/karukan) that converts kana to kanji with a small language model run by llama.cpp.

It is used as a dictionary of SKK input methods:

- [goda-skk.vim](https://github.com/Shougo/goda-skk.vim) asks it directly (`dictionary/karukan`).
- macSKK asks it through `skkserv-karukan-proxy` of [homebrew-yaskkserv2](https://github.com/delphinus/homebrew-yaskkserv2).

## Install

```sh
brew install delphinus/karukan/karukan-server
brew services start karukan-server
```

A bottle for `arm64_tahoe` (Apple silicon) is built by GitHub Actions, so the install does not need Rust or a C++ toolchain. Other platforms build from source.

`karukan-server` listens on `http://127.0.0.1:3000`. Its log is `$(brew --prefix)/var/log/karukan-server.log`.

When it starts for the first time, it downloads its models from Hugging Face into `~/.cache/huggingface`; until they are loaded, it answers `503`. It loads every model of the `[models]` table of karukan's `config.toml` (six by default), which takes about 900 MB of memory. A `[models]` table of your own adds to the default ones; it cannot remove them.

## Versions

Upstream has released only v0.1.0 (2026-02), so the formula pins a commit of master. Its version is the version of `karukan-cli` in `Cargo.toml`, then the date of the commit (`0.1.0.20261114`), so that it goes up while the Cargo version stays the same.

`upstream.yml` checks upstream master every Monday. When it has moved, it opens a pull request that moves the formula to the latest commit and starts `bottle.yml` on its branch to build and test it (a pull request opened by GitHub Actions triggers no `pull_request` workflow), and closes the older bump pull requests still open. Two commits of the same day give the same version, so it waits for a commit of a later day.

To move to another commit by hand:

1. Change the commit in `url` (and the comment above it), `sha256` and the date in `version`.
2. Remove the `bottle do ... end` block: it belongs to the old version.
3. Open a pull request. `bottle.yml` builds from source on it, which is where a build broken by upstream shows up.
4. Merge it. `bottle.yml` builds the bottle, uploads it to the release `karukan-server-<version>` and writes the `bottle` block back to main.

`brew install --HEAD delphinus/karukan/karukan-server` builds the latest master instead.

## License

karukan is under MIT OR Apache-2.0; its models (jinen, downloaded at runtime) are under CC BY-SA 4.0.
