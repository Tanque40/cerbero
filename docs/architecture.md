# Architecture

This document describes how Cerbero is built and how it is expected to grow. Decisions that are expensive to reverse live in [`docs/decisions/`](decisions/README.md); this file connects them. The [threat model](threat-model.md) explains why the boundaries are where they are.

## Crates

| Crate | Kind | Responsibility | May depend on |
| ----- | ---- | -------------- | ------------- |
| `cerbero-core` | library | Vault format, key derivation, encryption, entry model. Pure functions over bytes: no files, terminal, environment, clock, network or global state. | Approved crypto crates, `thiserror`, serialization. Never on another Cerbero crate. |
| `cerbero-cli` | binary `cerbero` | Argument parsing, prompts, reading and writing vault files, launching SSH/RDP clients, exit codes. | `cerbero-core` and CLI-only crates. |
| `cerbero-server` (phase 3) | binary | Stores and syncs encrypted vault blobs and wrapped keys. Never sees plaintext or user keys. | `cerbero-core` for format parsing only. |
| `cerbero-web` (phase 4) | binary or front end | Internal web interface. Decrypts in the client, never on the server. | To be decided by ADR. |

Rules:

- Dependencies point toward `cerbero-core`, never away from it.
- New crates go under `crates/` and must be added to this table.
- Anything that touches files, time or randomness in the core is passed in by the caller. The public API may use the operating system's random number generator; a crate-private variant takes nonces and salts as parameters for test vectors.

## Key hierarchy (phase 1 and 2)

```
master password ──Argon2id(salt, params)──▶ password KEK ──┐
                                                            ├─ wraps ─▶ data key (random, 256-bit)
recovery key (random, shown once) ─────────▶ recovery KEK ─┘                │
                                                                           ▼
                                               XChaCha20-Poly1305 over vault entries
```

- The data key never changes when the password or recovery key changes; only its wrapped copies are rewritten.
- The header stores format version, algorithm identifiers, Argon2id parameters, salts and both wrapped data keys. The whole header is authenticated as associated data.

## Data flow: opening a vault and using an entry

1. The CLI reads the vault file into memory and the master password from the terminal without echo.
2. `cerbero-core` parses the header, rejects unknown versions or algorithms, derives the KEK, unwraps the data key and decrypts entries into zeroizing types.
3. The CLI shows entry names and metadata. It reveals or hands off a secret only on explicit request.
4. When the command ends, every secret type is dropped and wiped.

## Errors

- `cerbero-core` returns typed errors (`thiserror`) that never contain secret material. Decryption failures do not say which part failed beyond "wrong password or corrupted vault", to avoid oracles.
- `cerbero-cli` maps errors to messages and exit codes: `0` success, `1` operation failed, `2` usage error.

## Growing into phase 3

The team server stores what clients already encrypt. Sharing an entry wraps its key to each member's public key with hybrid X25519 + ML-KEM-768, recorded as a new algorithm identifier in the same format. Roles, Shamir-split recovery and hypervisor-credential tiers are designed in their own ADRs before server code starts.
