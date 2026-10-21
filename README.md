# rust-template

Starting point for new Rust projects: strict linting, dev recipes, and security CI already wired up.

## Start a project

```sh
git clone git@github.com:stubbedev/rust-template.git myproject
cd myproject
rm -rf .git && git init -b main
# rename the crate
sd 'rust-template' 'myproject' Cargo.toml Cargo.lock
just check
```

## Recipes

| Recipe | What it does |
| --- | --- |
| `just check` | Every release gate in order: fmt-check, lint, test, build |
| `just fmt-check` | Fail when a source is not rustfmt-formatted |
| `just lint` | `cargo clippy` against the strict levels in `Cargo.toml` |
| `just test` | `cargo nextest run` (profiles in `.config/nextest.toml`) |
| `just build` | Compile-check every target |
| `just fmt` | Format every Rust source in place |
| `just watch [job]` | Rerun a bacon job on every save (`clippy-all` by default, or `nextest`, `run`, ...) |

Every dev tool (the Rust toolchain the package builds with, rust-analyzer,
clippy, rustfmt, cargo-nextest, bacon, cargo-audit, just, git, gh) comes from the flake: `direnv
allow` on entry, or `nix develop` explicitly.

## Fast iteration

- The dev shell links with mold (`useMoldLinker` over `clangStdenv` in
  `nix/shell.nix`), which cuts most of an incremental rebuild's time. It
  applies only inside the shell; `nix build` and other machines keep the
  default linker.
- `[profile.dev]` keeps only line tables as debuginfo: backtraces still
  carry file and line, but compiling and linking emit far less.

## Nix

- `nix build` builds the package (`nix/package.nix`; the dev shell is
  `nix/shell.nix`, both imported by `flake.nix`). Name, version and
  description come from `Cargo.toml`, dependencies from `Cargo.lock`;
  its tests run under nextest too.
- `nix run` runs it
- `nix fmt` formats the nix files with alejandra

## CI

`.github/workflows/security.yml` runs CodeQL (Rust and GitHub Actions), Grype and
cargo-audit, uploading CodeQL and Grype findings to code scanning; dependency
review gates pull requests. Dependabot keeps the crates and the workflows current.

## Linting

`Cargo.toml`'s `[lints]` denies clippy's `all`, `pedantic` and `cargo` groups,
plus `unwrap_used`, `expect_used`, `dbg_macro`, `print_stderr`, `todo` and
`implicit_return`, so every function returns with an explicit `return`
(`needless_return` is allowed because it contradicts `implicit_return`);
`unsafe_code` is forbidden. `just lint` passes `-D warnings`, so every finding
fails the build.
