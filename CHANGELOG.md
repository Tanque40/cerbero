# Changelog

All notable changes to this project are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html) once it publishes a release.

## [Unreleased]

### Added

- Initial project structure generated from AI Project Starter, licensed AGPL-3.0-only.
- Cargo workspace with `cerbero-core` and `cerbero-cli`, pinned toolchain and workspace lints.
- `make check` runs rustfmt, clippy, tests and cargo-deny; CI runs it on Linux and tests on macOS.
- Decision records 0001-0004 and Rust rules for handling secrets.
- Threat model, architecture overview, code and commit conventions.
- `make lint` with typos, zizmor and cargo-machete, run in CI.
- `scripts/github-settings.sh` to apply repository settings and the `main` ruleset.
- Draft specification of vault format version 1 (`docs/format/vault-v1.md`) and decision record 0005.
- Test layout (`docs/testing.md`): integration tests for the core, end-to-end tests for the CLI, and folders for test vectors and fuzzing.
