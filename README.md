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
| `just check` | Every release gate in order: fmt-check, lint, deny, test, build |
| `just fmt-check` | Fail when a source is not rustfmt-formatted |
| `just lint` | `cargo clippy` against the strict levels in `Cargo.toml` |
| `just deny` | `cargo deny check` against `deny.toml` |
| `just test` | `cargo nextest run` (profiles in `.config/nextest.toml`) |
| `just build` | Compile-check every target |
| `just fmt` | Format every Rust source in place |
| `just watch [job]` | Rerun a bacon job on every save (`clippy-all` by default, or `nextest`, `run`, ...) |

Every dev tool (the Rust toolchain the package builds with, rust-analyzer,
clippy, rustfmt, cargo-nextest, bacon, cargo-deny, just, git, gh) comes from the flake: `direnv
allow` on entry, or `nix develop` explicitly.

## Fast iteration

- The dev shell links with mold (`useMoldLinker` over `clangStdenv` in
  `nix/shell.nix`), which cuts most of an incremental rebuild's time. It
  applies only inside the shell; `nix build` and other machines keep the
  default linker.
- `[profile.dev]` keeps only line tables as debuginfo: backtraces still
  carry file and line, but compiling and linking emit far less.

## Nix

The package and its checks are built with [crane](https://github.com/ipetkov/crane)
(`nix/package.nix`; the dev shell is `nix/shell.nix`, both imported by
`flake.nix`). Dependencies build once into their own derivation, so editing
the crate's own code never rebuilds them.

- `nix build` builds the release package; name, version and description
  come from `Cargo.toml`, dependencies from `Cargo.lock`
- `nix flake check` runs `just fmt-check`, `just lint`, `just test` (nextest's
  `ci` profile) and `just deny bans licenses sources` in the sandbox, so the
  justfile stays the one definition of each gate. Advisories need network
  access the sandbox lacks, so the security workflow checks them instead.
- `nix run` runs it
- `nix fmt -- flake.nix nix` formats the nix files with alejandra

## CI

`.github/workflows/ci.yml` runs `nix flake check` on every pull request and
push to `main`. `.github/workflows/security.yml` runs CodeQL (Rust and GitHub
Actions), Grype and `just deny advisories` in the nix dev shell, also nightly,
uploading CodeQL and Grype findings to code scanning; dependency review gates
pull requests. Dependabot keeps the crates and the workflows current.

## Linting

`Cargo.toml`'s `[lints]` denies clippy's `all`, `pedantic` and `cargo` groups
plus a curated set of `restriction` and `nursery` lints, and `just lint`
passes `-D warnings`, so every finding fails the build. The extra lints:

- forbid panicking paths: `unwrap_used`, `expect_used`, `panic`,
  `unreachable`, `todo`, `unimplemented`, `indexing_slicing`, `string_slice`,
  `unwrap_in_result`, `panic_in_result_fn`, `get_unwrap`, `exit`
- forbid swallowed errors: `map_err_ignore`, `let_underscore_must_use`,
  `unused_result_ok`, `assertions_on_result_states`
- forbid silent suppressions: `allow_attributes` and
  `allow_attributes_without_reason`, so every exception is an
  `#[expect(lint, reason = "...")]` that errors once it no longer applies
- keep output deterministic: `iter_over_hash_type`
- require explicit `return`: `implicit_return` (`needless_return`
  contradicts it and is allowed)
- `nursery` lints can report false positives; answer those with an `#[expect]`

`clippy.toml` lifts the panic, unwrap, expect, indexing and `dbg!` lints
inside tests, where panicking is how a test fails. `unsafe_code` is forbidden.

`deny.toml` holds the dependency policy `just deny` enforces: no known
advisories or yanked crates, an allowlist of licences, crates.io as the only
source, no wildcard requirements and no duplicate crate versions.
Duplicates are checked there instead of by clippy's `multiple_crate_versions`
because `[bans] skip` can exempt one crate at a time.
