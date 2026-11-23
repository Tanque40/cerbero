# 0003. Derive keys with Argon2id and encrypt with XChaCha20-Poly1305

- Status: Accepted
- Date: 2026-11-18
- Deciders: @Tanque40

## Context

A personal vault is unlocked with a master password. The password must be stretched into a key that resists offline guessing, and the contents must be encrypted with authenticated encryption that is hard to misuse.

## Options considered

1. **Argon2id + XChaCha20-Poly1305.** Argon2id is the memory-hard password hash recommended by RFC 9106 and OWASP. XChaCha20-Poly1305 has a 24-byte nonce, so random nonces are safe, and it is fast without hardware AES.
2. **PBKDF2 or scrypt + AES-256-GCM.** Widely available, but PBKDF2 is not memory-hard, and AES-GCM's 12-byte nonce makes random nonces risky at scale and misuse catastrophic.

## Decision

Use Argon2id (`argon2` crate) to derive a key-encryption key from the master password, and XChaCha20-Poly1305 (`chacha20poly1305` crate) for all symmetric encryption. A random data key encrypts the vault; the password-derived key only wraps the data key. Argon2id parameters are stored in the vault header so they can be raised later.

## Consequences

Symmetric-only personal vaults are considered safe against quantum attackers with 256-bit keys. Default Argon2id parameters must be chosen and measured on the maintainers' machines before format version 1.

## Verification

None yet. Known-answer tests for both primitives will be added with the first implementation.
