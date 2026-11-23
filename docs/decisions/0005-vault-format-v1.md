# 0005. Lay out vault format version 1 as one encrypted payload with two key slots

- Status: Accepted
- Date: 2026-11-23
- Deciders: @Tanque40

## Context

[ADR 0002](0002-own-versioned-vault-format.md), [0003](0003-argon2id-and-xchacha20-poly1305.md) and [0004](0004-recovery-key.md) fixed the principles: our own versioned format, Argon2id and XChaCha20-Poly1305, a random data key wrapped by the password and by a recovery key. The [format specification](../format/vault-v1.md) turns them into bytes, which needs five more choices that are expensive to change once vaults exist.

## Options considered

1. **How entries are encrypted.**
   - *One encrypted payload for all entries (chosen).* The file reveals only its size rounded to 4 KiB. One nonce and one tag per save. Every save rewrites the whole file, which is cheap at the sizes a personal vault reaches.
   - *Each entry encrypted separately.* Allows partial updates and per-entry sharing, but reveals the number of entries and each entry's size, and needs an authenticated index to stop entries from being removed or reordered.
2. **How the payload is encoded.**
   - *Our own length-prefixed binary layout (chosen).* No new dependency, every byte specified, easy to fuzz, and we control every copy of secret bytes.
   - *CBOR (`ciborium`) or `postcard` with serde.* Less code to write, but adds a dependency on the most exposed parser, and serde deserializers can leave unwiped copies of secrets in intermediate buffers.
3. **Default Argon2id parameters.**
   - *64 MiB, t=3, p=4 (RFC 9106 second option).* About 0.12 s in the development container. Kept as the writer minimum.
   - *128 MiB, t=3, p=4.* About 0.30 s in the development container. Half the attacker's cost per guess compared with 256 MiB.
   - *256 MiB, t=3, p=4 (chosen).* About 0.6 s in the development container (0.57 to 0.64 s over three runs). A vault is opened a few times a day, so a slower unlock buys four times the cost per guess.
   - *1 GiB or more.* About 1.8 s at t=2 in the container, and risky on machines with little free memory.
4. **How the recovery key becomes a key-encryption key.**
   - *Use its 32 random bytes directly (chosen).* It already has 256 bits of entropy, and the slot type in the associated data separates it from other keys. No new crate.
   - *Derive it with HKDF or Argon2id.* HKDF needs a new cryptographic crate and adds nothing for a uniformly random key; Argon2id would only slow down recovery.
5. **How the recovery key is shown.**
   - *Crockford Base32 in groups of four with a mod-37 check symbol (chosen).* 53 characters, no ambiguous letters, typos caught before unwrapping, implemented in a few lines without a dependency.
   - *BIP39 24-word mnemonic.* Easier to read aloud, but needs SHA-256 and a word list (new crates), and the word list is English.

The password is normalized to Unicode NFC before Argon2id, so the same password typed on macOS and Linux gives the same key. This adds the `unicode-normalization` crate, which is not cryptographic.

## Decision

Adopt the [vault format version 1 specification](../format/vault-v1.md) with the options marked as chosen above.

## Consequences

- The header holds exactly two slots in version 1, each authenticated on its own, so changing the password never needs the recovery key and the reverse.
- The whole file is rewritten on every save. If vaults grow past a few megabytes or phase 3 needs per-entry sharing, a new format version or slot type will be needed; existing vaults keep working.
- Rollback to an older copy is not detected by the format; `revision` lets the CLI warn. Key commitment is not provided; phase 3 must revisit it before the server accepts ciphertexts.
- The default Argon2id parameters must be measured on the maintainers' machines before version 1 is declared stable.

## Verification

The test vectors and generated tests listed in [section 11 of the specification](../format/vault-v1.md#11-test-vectors), and fuzz targets for the header parser, payload parser and recovery key decoder. `FORMAT_VERSION` stays 0 until they pass.
