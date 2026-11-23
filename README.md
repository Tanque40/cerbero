# Cerbero

Cerbero is a password and secrets vault for infrastructure administrators. It starts as a personal command-line tool for passwords, SSH keys and server credentials, and will grow into an end-to-end encrypted team vault. The server never sees plaintext.

> **Status: early development.** There is no stable vault format yet. Do not store real secrets in it.

## Design at a glance

- Written in Rust, with `unsafe` code forbidden ([ADR 0001](docs/decisions/0001-use-rust.md)).
- Own versioned vault format with explicit algorithm identifiers ([ADR 0002](docs/decisions/0002-own-versioned-vault-format.md)).
- Argon2id for the master password, XChaCha20-Poly1305 for encryption ([ADR 0003](docs/decisions/0003-argon2id-and-xchacha20-poly1305.md)).
- Recovery key from the first version ([ADR 0004](docs/decisions/0004-recovery-key.md)).

## Build and check

You need [rustup](https://rustup.rs/); it installs the toolchain pinned in `rust-toolchain.toml` on first use. Install cargo-deny once:

```sh
cargo install --locked cargo-deny
```

Then, from the repository root:

```sh
make check                              # fmt, clippy, tests and cargo-deny
make lint                               # typos, zizmor, cargo-machete (optional locally, required in CI)
cargo run -p cerbero-cli -- --version   # run the CLI
```

| Path | Contents |
| ---- | -------- |
| `crates/cerbero-core` | Vault format and cryptography. No I/O. |
| `crates/cerbero-cli` | The `cerbero` command. |
| `docs/decisions` | Decision records. |
| `docs/languages/rust.md` | Coding and secret-handling rules. |
| `docs/architecture.md` | Crates, key hierarchy and data flow. |
| `docs/threat-model.md` | What Cerbero protects, from whom, and what is out of scope. |
| `docs/testing.md` | Where tests go and what must be covered. |
| `scripts/github-settings.sh` | Repository settings applied with `gh`. |
| `fuzz/` | Fuzz targets (nightly, outside the workspace). |

## Working together

See the [contribution guide](CONTRIBUTING.md), [Contributor License Agreement](CLA.md), [code of conduct](CODE_OF_CONDUCT.md), [security reporting policy](SECURITY.md), [decision records](docs/decisions/README.md) and [instructions for AI assistants](AGENTS.md). `CLAUDE.md` imports the same instructions.

## License

Cerbero is licensed under the [GNU Affero General Public License v3.0 only](LICENSE). Files inherited from the AI Project Starter template keep the MIT notice in [`LICENSES/template-MIT.txt`](LICENSES/template-MIT.txt).
