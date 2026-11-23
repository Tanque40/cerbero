# 0002. Use our own versioned vault format

- Status: Accepted
- Date: 2026-11-18
- Deciders: @Tanque40

## Context

The vault needs an on-disk format that will outlive several versions of the tool and allow its cryptography to change, including adding post-quantum key exchange when vaults are shared with a team.

## Options considered

1. **The `age` file format.** Well designed and reviewed, but it encrypts files, not structured vaults, and its recipient model does not cover password-based key wrapping with a recovery key and later team sharing without extensions.
2. **Our own format with explicit versioning.** More design and review work, but it can describe entries, key wrapping and sharing directly.

## Decision

Define our own format. Every vault header carries a format version and the identifiers of the algorithms used (key derivation, encryption, key wrapping), and the header is authenticated as associated data. Version 1 is the first stable format; `cerbero_core::FORMAT_VERSION` is 0 until then.

## Consequences

The format needs a written specification, test vectors and fuzzing of the parser before version 1 is declared stable. Readers must reject unknown versions and algorithm identifiers instead of guessing. Team sharing (phase 3) will add hybrid X25519 + ML-KEM-768 key wrapping as a new algorithm identifier, not a new format.

## Verification

None yet. The format specification and its test vectors will add checks.
