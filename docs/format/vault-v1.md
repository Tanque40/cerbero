# Vault format, version 1

- Status: Draft. The format is stable only when `cerbero_core::FORMAT_VERSION` is 1, its test vectors are committed and [ADR 0005](../decisions/0005-vault-format-v1.md) is accepted.
- Decisions behind it: [ADR 0002](../decisions/0002-own-versioned-vault-format.md) (own versioned format), [ADR 0003](../decisions/0003-argon2id-and-xchacha20-poly1305.md) (Argon2id and XChaCha20-Poly1305), [ADR 0004](../decisions/0004-recovery-key.md) (recovery key), [ADR 0005](../decisions/0005-vault-format-v1.md) (the choices in this document).

This document is the normative description of a Cerbero vault file. An implementation that follows it byte for byte must be able to open every vault that Cerbero writes. The words MUST, MUST NOT, SHOULD and MAY are used as in RFC 2119.

## 1. Goals

1. Someone holding the file learns only the format version, the Argon2id parameters, and the vault size rounded up to 4 KiB ([threat model](../threat-model.md), adversary 1).
2. Any change to any byte is detected before plaintext is used, and no partial plaintext is ever returned (adversary 2).
3. The master password and the recovery key each open the vault on their own. Changing one never invalidates the other, and neither change re-encrypts the entries with a new key ([ADR 0004](../decisions/0004-recovery-key.md)).
4. A reader rejects any version, algorithm, slot type or flag it does not know, instead of guessing.
5. Team sharing (phase 3) can be added as new slot types and algorithm identifiers without changing what existing fields mean.

Not a goal in version 1: hiding the number of entries beyond the 4 KiB padding, detecting rollback to an older copy of the same vault (see [section 9](#9-security-notes)), or concurrent writers.

## 2. Conventions

- All integers are unsigned and little-endian unless noted. `u8`, `u16`, `u32`, `u64` have 1, 2, 4 and 8 bytes. `i64` is a two's-complement signed 64-bit integer, little-endian.
- `a || b` is the concatenation of byte strings.
- Strings are UTF-8 without a terminator, preceded by their length in bytes.
- Every random value (data key, salt, nonce, vault id, entry id, recovery key) comes from the operating system's random number generator. The only exception is a crate-private function used by test vectors ([testing rules](../testing.md#rules)).
- `AEAD(key, nonce, aad, plaintext)` is XChaCha20-Poly1305 as specified in [draft-irtf-cfrg-xchacha-03](https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-xchacha-03): 32-byte key, 24-byte nonce, output is the ciphertext followed by a 16-byte tag.

## 3. Keys

```
master password ──Argon2id(salt, m, t, p)──▶ password KEK (32 B) ──┐
                                                                     ├─ AEAD wraps ─▶ data key (32 B, random)
recovery key (32 B, random) ──── used directly as ──▶ recovery KEK ─┘                    │
                                                                                         ▼
                                                     AEAD(data key, payload nonce, header) ─▶ payload
```

| Key | Size | Origin | Lifetime |
| --- | ---- | ------ | -------- |
| Data key | 32 bytes | Random, generated when the vault is created. | Life of the vault. Never written in plain text. |
| Password KEK | 32 bytes | `Argon2id(password, salt, m, t, p)`, version 0x13, output length 32, no secret value, no associated data. | One operation. Wiped after unwrapping or wrapping. |
| Recovery key | 32 bytes | Random, generated at creation or rotation. Shown once ([section 7](#7-recovery-key-encoding)). | Kept offline by the user. Never stored by Cerbero. |
| Recovery KEK | 32 bytes | The recovery key bytes, used without a derivation step. | One operation. |

The recovery key already has 256 bits of entropy, so stretching it adds nothing; using it directly avoids a new key-derivation crate. Each wrap binds its slot type in the associated data ([section 5](#5-key-slots)), so the same 32 bytes cannot be confused between slots.

The password is passed to Argon2id as the exact UTF-8 bytes the user typed, after Unicode normalization form NFC. Implementations MUST NOT trim or otherwise change it.

## 4. File layout

A vault file is a header followed by the encrypted payload, and nothing else.

```
┌──────────────────────────────── header (255 bytes in version 1) ───────────────────────────────┐
│ fixed prefix (30) │ slot_count (1) │ password slot (121) │ recovery slot (75) │ nonce (24) │ len (4) │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
┌──────── payload ciphertext (payload_length bytes) ────────┐
│ AEAD(data key, payload_nonce, header, padded plaintext)   │
└───────────────────────────────────────────────────────────┘
```

### 4.1 Header

| Offset | Size | Field | Value in version 1 |
| ------ | ---- | ----- | ------------------ |
| 0 | 8 | `magic` | `43 45 52 42 45 52 4F 00` (`"CERBERO"` followed by a zero byte) |
| 8 | 2 | `format_version` | `1` |
| 10 | 2 | `flags` | `0`. Every bit is reserved. |
| 12 | 16 | `vault_id` | Random. Set at creation and never changed. |
| 28 | 2 | `aead_id` | `0x0001` = XChaCha20-Poly1305. Used for key wrapping and for the payload. |
| 30 | 1 | `slot_count` | `2` |
| 31 | 121 | slot 0 | Password slot ([5.1](#51-password-slot-type-0x01)) |
| 152 | 75 | slot 1 | Recovery slot ([5.2](#52-recovery-slot-type-0x02)) |
| 227 | 24 | `payload_nonce` | Random, new on every write. |
| 251 | 4 | `payload_length` | Length of the payload ciphertext, including its 16-byte tag. |

The **fixed prefix** is bytes 0 to 29 (`magic` through `aead_id`). The **header** is bytes 0 to 254, from `magic` through `payload_length`. The payload ciphertext starts at byte 255 and the file MUST end exactly at `255 + payload_length`.

### 4.2 Reader checks before any key derivation

A reader MUST perform these checks, in this order, and stop at the first failure. None of them needs a secret, so they run before Argon2id and bound the work an untrusted file can cause.

1. The file is at least 255 bytes long and `magic` matches.
2. `format_version` is 1. Any other value: error "unsupported format version".
3. `flags` is 0.
4. `aead_id` is `0x0001`.
5. `slot_count` is 2, slot 0 has type `0x01`, slot 1 has type `0x02`, and each `body_length` is the exact value in [section 5](#5-key-slots).
6. The password slot's `kdf_id` is `0x0001` and its parameters are within the reader bounds in [section 6](#6-argon2id-parameters).
7. `payload_length` is at least 16 + 4096, at most 64 MiB + 16, and `payload_length - 16` is a multiple of 4096.
8. The file length is exactly `255 + payload_length`.

Errors from these checks MAY say which check failed, because they reveal nothing about the password. Errors after this point MUST NOT ([section 8.1](#81-opening)).

### 4.3 Payload

```
payload_ciphertext = AEAD(data key, payload_nonce, header, padded_plaintext)
```

The associated data is the full 255-byte header, so changing any header byte, including the slots and the Argon2id parameters, makes the payload fail to decrypt even when an attacker leaves the wrapped keys alone.

`padded_plaintext` is:

| Size | Field | Notes |
| ---- | ----- | ----- |
| 8 | `revision` | Starts at 1 and increases by 1 on every write. |
| 4 | `entry_count` | At most 100 000. |
| variable | entries | `entry_count` entries, back to back. |
| variable | padding | Zero bytes up to the smallest multiple of 4096 that holds everything above. May be empty. |

A reader MUST reject a payload whose padding contains a non-zero byte, or whose entries end past the plaintext.

#### Entry

| Size | Field | Rules |
| ---- | ----- | ----- |
| 16 | `entry_id` | Random. Unique within the vault. |
| 2 | `kind` | `1` login, `2` SSH key, `3` RDP, `4` hypervisor console, `5` secure note. Other values are rejected. |
| 8 | `created` | `i64`, seconds since the Unix epoch, UTC. Supplied by the caller. |
| 8 | `modified` | `i64`, same encoding, not earlier than `created`. |
| 2 | `name_length` | 1 to 1024. |
| `name_length` | `name` | UTF-8. Shown in listings; not secret. |
| 2 | `field_count` | At most 256. |
| variable | fields | `field_count` fields. |

#### Field

| Size | Field | Rules |
| ---- | ----- | ----- |
| 1 | `field_name_length` | 1 to 64. |
| `field_name_length` | `field_name` | ASCII `a`-`z`, `0`-`9` and `_`. Unique within the entry. |
| 1 | `field_flags` | Bit 0: secret (hidden unless the user asks to reveal it). Bits 1 to 7 are zero. |
| 4 | `value_length` | At most 1 MiB. |
| `value_length` | `value` | Bytes. Text fields are UTF-8; key material may be binary. |

The CLI defines well-known field names per kind (for example `username`, `password`, `host`, `port`, `private_key`, `public_key`). They are conventions of the CLI, not part of the format, so adding one never needs a new format version.

## 5. Key slots

A slot holds one wrapped copy of the data key. Every slot has the same outer shape:

| Size | Field |
| ---- | ----- |
| 1 | `slot_type` |
| 2 | `body_length` |
| `body_length` | `body` |

The associated data of a slot's wrap is:

```
slot_aad = fixed_prefix || slot_type || body_length || slot_params
```

where `slot_params` is every byte of the body before `wrap_nonce`. The slot AAD deliberately excludes the other slot, `slot_count`, the payload nonce and the payload length. That is what lets Cerbero rewrite the password slot without knowing the recovery key, and the reverse ([section 8.3](#83-changing-the-master-password)). The whole header, including both slots, is still authenticated by the payload ([section 4.3](#43-payload)).

### 5.1 Password slot (type `0x01`)

`body_length` = 118.

| Size | Field | Notes |
| ---- | ----- | ----- |
| 2 | `kdf_id` | `0x0001` = Argon2id, version 0x13 (RFC 9106). |
| 4 | `m_cost` | Memory in KiB. |
| 4 | `t_cost` | Iterations. |
| 4 | `p_cost` | Lanes. |
| 32 | `salt` | Random, new every time this slot is written. |
| 24 | `wrap_nonce` | Random, new every time this slot is written. |
| 48 | `wrapped_data_key` | `AEAD(password KEK, wrap_nonce, slot_aad, data key)`: 32 bytes of ciphertext and a 16-byte tag. |

`slot_params` for this slot is `kdf_id || m_cost || t_cost || p_cost || salt` (46 bytes).

### 5.2 Recovery slot (type `0x02`)

`body_length` = 72.

| Size | Field |
| ---- | ----- |
| 24 | `wrap_nonce` |
| 48 | `wrapped_data_key` = `AEAD(recovery KEK, wrap_nonce, slot_aad, data key)` |

`slot_params` for this slot is empty.

### 5.3 Reserved slot types

`0x00` and `0xFF` are never used. Types `0x03` and above are reserved for later phases, for example a hybrid X25519 + ML-KEM-768 recipient slot for team sharing. A version 1 reader rejects them.

## 6. Argon2id parameters

| | `m_cost` | `t_cost` | `p_cost` |
| - | -------- | -------- | -------- |
| Reader bounds (reject outside) | `8 × p_cost` to 4 194 304 KiB (4 GiB) | 1 to 32 | 1 to 16 |
| Writer minimum (public API refuses less) | 65 536 KiB (64 MiB) | 2 | 1 |
| Default for new vaults | 262 144 KiB (256 MiB) | 3 | 4 |

- The reader bounds only stop a hostile file from making Cerbero allocate or compute without limit. They are not a security floor: lowering the parameters in a file changes the password KEK, so the unwrap fails.
- The writer minimum is RFC 9106's second recommended option, the floor below which Cerbero will not create or rewrite a vault through its public API. Test vectors use smaller values through the crate-private function.
- The default takes about 0.6 seconds on one core of the cloud development container (measured 2026-11-23 with `argon2` 0.5, which computes lanes one after another unless its `parallel` feature is on). It must be measured on the maintainers' machines before version 1 is declared stable ([ADR 0003](../decisions/0003-argon2id-and-xchacha20-poly1305.md)); the target is 0.5 to 1 second.
- The CLI SHOULD offer to raise the parameters when it opens a vault whose parameters are below the current default, by rewriting the password slot ([section 8.3](#83-changing-the-master-password)).

## 7. Recovery key encoding

The recovery key is shown once, for the user to write down or print, and typed back only to recover.

- Encode the 32 bytes as [Crockford Base32](https://www.crockford.com/base32.html): the bytes as a big-endian bit string, padded with 4 zero bits, in 52 symbols from `0123456789ABCDEFGHJKMNPQRSTVWXYZ`.
- Append one check symbol: the 256-bit big-endian integer formed by the 32 bytes, modulo 37, written with Crockford's check alphabet (`0`-`Z` as above, then `*`, `~`, `$`, `=`, `U` for 32 to 36). It detects any single wrong symbol and any swap of two adjacent symbols.
- Display it in 13 groups of 4 symbols separated by hyphens, with the check symbol at the end of the last group: `XXXX-XXXX-...-XXXXC`.
- When reading, ignore hyphens and spaces, accept lower case, read `O` as `0` and `I` or `L` as `1`, reject `U` except as the check symbol, reject non-zero padding bits, and report a failed check before trying to unwrap.

## 8. Operations

Every write produces a complete new file. Writing it safely to disk (temporary file, `fsync`, atomic rename, permissions `0600`) is the CLI's job and outside this format.

### 8.1 Opening

1. Run the checks in [section 4.2](#42-reader-checks-before-any-key-derivation).
2. With a password: derive the password KEK and unwrap slot 0. With a recovery key: decode it ([section 7](#7-recovery-key-encoding)) and unwrap slot 1.
3. Decrypt the payload with the data key and the full header as associated data.
4. Parse and validate the plaintext ([section 4.3](#43-payload)).

If step 2, 3 or 4 fails, the reader returns one error, "wrong password or corrupted vault" (or "wrong recovery key or corrupted vault"), returns no plaintext, and wipes every intermediate key and buffer. Step 4 can only fail on a file written by a buggy writer, since the payload is authenticated, but it gets the same treatment.

### 8.2 Creating

Generate `vault_id`, the data key, the recovery key, a salt and three nonces. Write the password slot with the default parameters, the recovery slot, and a payload with `revision` 1 and no entries. Return the recovery key to the caller so the CLI can show it once.

### 8.3 Changing the master password

With the vault open (by password or recovery key): new salt, new wrap nonce, optionally new Argon2id parameters, wrap the same data key under the new password KEK, keep slot 1 byte for byte, then re-encrypt the payload with a new `payload_nonce` and `revision + 1` because the header changed. The recovery key keeps working.

### 8.4 Rotating the recovery key

The same with the roles swapped: new recovery key, new wrap nonce for slot 1, slot 0 kept byte for byte, payload re-encrypted. The old recovery key stops working; the master password keeps working. The CLI SHOULD require the master password, not the recovery key, for this operation.

### 8.5 Saving changes to entries

New `payload_nonce`, `revision + 1`, both slots unchanged.

The data key never changes in version 1. Replacing it (for example after a suspected leak of a decrypted copy) means creating a new vault and moving the entries, which also creates a new recovery key.

## 9. Security notes

- **Nonces.** Every AEAD call uses a fresh random 24-byte nonce. A vault sees at most a few thousand encryptions under one key, far below the bound where random 192-bit nonces could collide.
- **Integrity before use.** Slots are authenticated by their own wrap, and the payload authenticates the whole header. No field after the [reader checks](#42-reader-checks-before-any-key-derivation) is trusted until the payload tag verifies.
- **Rollback.** An attacker who can replace the file can put back an older, valid copy of the same vault. Version 1 does not prevent this. `revision` lets the CLI warn when it sees a lower revision than the last one it remembers for a `vault_id`; the team server in phase 3 is where rollback is enforced.
- **Key commitment.** XChaCha20-Poly1305 is not key-committing. This matters for partitioning-oracle attacks, where an attacker submits crafted ciphertexts to a service that tries many keys. A local vault opened with one password is not exposed to that. The team server must revisit it in phase 3 before accepting ciphertexts from clients.
- **Metadata.** The header reveals the Argon2id parameters and that the file is a Cerbero vault. Entry names, kinds, counts and timestamps are inside the encrypted payload.
- **Memory.** Implementations hold the password, KEKs, data key, recovery key and decrypted payload in zeroizing types and never copy them into types that are not wiped ([Rust rules](../languages/rust.md#secret-material)).

## 10. Extending the format

- A change that an older reader could misread gets a new `format_version`.
- A new algorithm gets a new `aead_id` or `kdf_id`; a new way to hold the data key gets a new slot type. Version 1 readers reject both, which is the intended behavior: they fail clearly instead of opening a vault they cannot protect.
- A new entry kind or field flag is a format change for the payload. Until a later version defines them, readers reject unknown values.
- Every published version keeps its test vectors forever ([testing rules](../testing.md#rules)).

## 11. Test vectors

These must be committed under `crates/cerbero-core/tests/vectors/` and loaded by `tests/vectors.rs` before `FORMAT_VERSION` becomes 1. All secrets in them are synthetic.

| File | Contents |
| ---- | -------- |
| `argon2id-rfc9106.json` | The Argon2id known-answer test from RFC 9106 section 5.3. |
| `xchacha20poly1305-draft03.json` | The AEAD test vector from draft-irtf-cfrg-xchacha-03 appendix A.3.1. |
| `recovery-key-encoding.json` | Byte strings and their encodings, including all-zero, all-`0xFF`, and keys whose check symbol is each of `*`, `~`, `$`, `=`, `U`; plus inputs that must be rejected (bad check, bad padding bits, wrong length). |
| `vault-v1-empty.json` | A vault with no entries, with Argon2id at `m_cost = 32, t_cost = 1, p_cost = 4`, fixed `vault_id`, data key, salt, nonces, password and recovery key, and the exact expected file bytes. |
| `vault-v1-entries.json` | The same keys with one entry of each kind, including a binary field value, a non-ASCII name and an empty value. |
| `vault-v1-password-changed.json` | `vault-v1-empty` after a password change: slot 1 is byte-identical and the old recovery key still opens it. |

Each `vault-v1-*` vector is checked two ways: the crate-private writer, given the fixed inputs, must produce the expected bytes exactly; and the public reader must open the expected bytes with both the password and the recovery key.

Generated, not committed, in `tests/format.rs`:

- Flipping any single bit of `vault-v1-entries` fails to open with both keys, and returns no plaintext.
- Truncating the file at every length, or appending one byte, is rejected.
- Each reader check in [section 4.2](#42-reader-checks-before-any-key-derivation) has a test with a file that fails only that check.
- A payload with a non-zero padding byte, a duplicate entry id, a duplicate field name or an unknown kind is rejected even when correctly encrypted (built with the crate-private writer).
- Property test with `proptest`: for generated entries, open(save(entries)) returns the same entries.

Fuzz targets in `fuzz/`: the header parser, the payload parser given arbitrary plaintext, and the recovery key decoder.
