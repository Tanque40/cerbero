# 0001. Use Rust for the vault and its tools

- Status: Accepted
- Date: 2026-11-18
- Deciders: @Tanque40

## Context

Cerbero stores passwords, SSH keys and infrastructure credentials. A memory-safety bug in the code that handles them can leak every secret at once. The project starts as a command-line tool for one person and later grows into a team server and a web interface.

## Options considered

1. **Rust.** Memory safety without a garbage collector, a mature audited cryptography ecosystem (RustCrypto), single static binaries for macOS, Linux and Windows, and control over wiping secrets from memory.
2. **Go.** Simple and fast to build, good standard cryptography, but the garbage collector copies memory freely, which makes wiping secrets unreliable.
3. **Python or another interpreted language.** Fastest to prototype, but secrets end up in immutable strings that cannot be wiped, and distribution to servers needs a runtime.

## Decision

Use Rust for all components, starting with a Cargo workspace of `cerbero-core` (format and cryptography, no I/O) and `cerbero-cli`.

## Consequences

Slower initial development and a steeper learning curve. In exchange, `unsafe` can be forbidden workspace-wide and secrets can be wiped deterministically.

## Verification

`unsafe_code = "forbid"` in the workspace lints and the rules in `docs/languages/rust.md`, both checked by `make check`.
