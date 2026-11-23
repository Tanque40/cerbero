#!/bin/sh
# SPDX-License-Identifier: AGPL-3.0-only
# Extra linters: spelling, GitHub Actions security and unused dependencies.
set -eu

missing=0
for tool in typos zizmor cargo-machete; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'missing tool: %s\n' "$tool" >&2
        missing=1
    fi
done
if [ "$missing" -ne 0 ]; then
    printf '%s\n' 'Install with: cargo install --locked typos-cli cargo-machete && pipx install zizmor' >&2
    exit 1
fi

typos
zizmor --offline .github/workflows/
cargo machete
