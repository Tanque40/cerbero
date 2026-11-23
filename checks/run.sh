#!/bin/sh
# SPDX-License-Identifier: AGPL-3.0-only
# Project check: formatting, lints, tests and dependency policy.
set -eu

cargo fmt --all --check
cargo clippy --workspace --all-targets --all-features --locked -- -D warnings
cargo test --workspace --all-features --locked

if ! command -v cargo-deny >/dev/null 2>&1; then
    printf '%s\n' 'cargo-deny is not installed. Install it with: cargo install --locked cargo-deny' >&2
    exit 1
fi
cargo deny --locked check
