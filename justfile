# rust-template dev tasks.

# List all recipes with their descriptions.
default:
    @just --list

# Run every release gate in order: fmt-check, lint, test, build.
check: fmt-check lint test build

# Fail when any source is not rustfmt-formatted.
fmt-check:
    cargo fmt --check

# Lint every target; the lint levels live in Cargo.toml's [lints].
lint:
    cargo clippy --all-targets --locked -- -D warnings

# Run the test suite with cargo-nextest; profiles live in .config/nextest.toml.
test:
    cargo nextest run --locked

# Compile-check every target.
build:
    cargo build --locked

# Format every Rust source in place with rustfmt.
fmt:
    cargo fmt
