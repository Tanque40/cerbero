# Rust rules

These rules apply to every crate in this workspace. `make check` enforces the ones marked **(enforced)**; reviewers check the rest.

## Toolchain and layout

- The toolchain is pinned in `rust-toolchain.toml`. Raise it in its own pull request and update `rust-version` in `Cargo.toml` at the same time.
- `crates/cerbero-core` holds the vault format and all cryptography. It performs no I/O: no files, terminal, environment variables or network. It never prints **(enforced: `clippy::print_stdout`, `clippy::print_stderr`)**.
- `crates/cerbero-cli` owns user interaction, files and process exit codes.
- `Cargo.lock` is committed. CI builds with `--locked`.
- Tests follow [`docs/testing.md`](../testing.md). Crate boundaries follow [`docs/architecture.md`](../architecture.md).

## Style and documentation

- `cargo fmt --all` formats everything **(enforced)**. Options are in `rustfmt.toml`; use only stable options.
- Every public item in `cerbero-core` has a doc comment **(enforced: `missing_docs`)**. Document what it does, its errors (`# Errors`) and, for anything that handles secrets, how long they live.
- Names follow the [Rust API guidelines](https://rust-lang.github.io/api-guidelines/naming.html). Name types after domain concepts (`Vault`, `Entry`, `DataKey`), not technical roles (`Manager`, `Helper`).
- One module per concept. Keep `lib.rs` and `main.rs` short: declarations, re-exports and wiring.
- Prefer newtypes over raw `Vec<u8>` or `String` for keys, nonces, salts and identifiers, so the compiler catches mix-ups.

## Safety and errors

- No `unsafe` code **(enforced: `unsafe_code = "forbid"`)**. A crate that needs it requires a decision record first.
- No `unwrap`, `expect`, `panic!`, `todo!` or `unimplemented!` outside tests **(enforced by clippy)**.
- `cerbero-core` returns typed errors defined with `thiserror`, one error enum per module or public operation. Errors never contain secret material, and decryption failures do not reveal which step failed.
- `cerbero-cli` turns errors into messages and exit codes: `0` success, `1` operation failed, `2` usage error.
- Clippy pedantic warnings fail the build **(enforced)**. Allow a specific lint locally with a comment that says why.

## Secret material

Secret material means master passwords, derived keys, data keys, recovery keys, decrypted entries and private SSH keys.

- Hold secrets in types that wipe memory on drop (`zeroize::Zeroizing`, `secrecy::SecretBox` or a type that derives `ZeroizeOnDrop`). Do not keep copies in `String` or `Vec<u8>` that outlive the operation.
- Secret types must not implement `Debug`, `Display` or `Serialize` in a way that reveals their contents. Redact instead (`[REDACTED]`).
- Never log, print, put in an error message or put in a panic message any secret or any value derived from one.
- Compare secrets and authentication tags in constant time (`subtle`), never with `==`.
- Read passwords from the terminal without echo. Never accept a secret as a command-line argument or an environment variable, because other processes and shell history can see them.
- Tests use synthetic secrets only, generated in the test or written as obviously fake constants.

## Cryptography

- Do not implement cryptographic primitives. Use audited crates from the [RustCrypto](https://github.com/RustCrypto) project or an equivalent that a decision record approves.
- Approved so far (see `docs/decisions/`): `argon2` (Argon2id), `chacha20poly1305` (XChaCha20-Poly1305), `zeroize`, `secrecy`, `subtle`, and `getrandom` or `rand_core::OsRng` for randomness. Adding another cryptographic crate needs a decision record.
- Every nonce for XChaCha20-Poly1305 is 24 random bytes from the operating system's generator. Never derive nonces from counters or timestamps.
- Every encrypted structure carries a format version and algorithm identifiers, authenticated as associated data, so that the format can change without guessing.

## Dependencies

- `cargo deny check` must pass **(enforced)**: no known advisories, no yanked crates, only licenses listed in `deny.toml`, only crates.io as a source.
- `cargo machete` must find no unused dependencies **(enforced in CI by `make lint`)**.
- Prefer few, widely used dependencies. Explain each new dependency in the pull request.
