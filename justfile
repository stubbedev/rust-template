# rust-template dev tasks.

# List all recipes with their descriptions.
default:
    @just --list

# Run every release gate in order: fmt-check, lint, deny, test, build.
check: fmt-check lint deny test build

# Fail when any source is not rustfmt-formatted.
fmt-check:
    cargo fmt --check

# Lint every target; the lint levels live in Cargo.toml's [lints].
lint:
    cargo clippy --all-targets --locked -- -D warnings

# Check advisories, licences, duplicate versions and sources against deny.toml.
deny:
    cargo deny --locked check

# Run the test suite with cargo-nextest; profiles live in .config/nextest.toml.
test:
    cargo nextest run --locked

# Compile-check every target.
build:
    cargo build --locked

# Rerun a bacon job on every save: clippy-all by default, or e.g. `just watch nextest`.
watch job="clippy-all":
    bacon {{job}}

# Format every Rust source in place with rustfmt.
fmt:
    cargo fmt
