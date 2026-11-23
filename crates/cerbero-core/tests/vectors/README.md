# Test vectors

Fixed inputs and expected outputs that must never change once committed. They prove that a vault written by one version of Cerbero still opens in every later version.

- `argon2id-*.json`: known-answer tests from RFC 9106.
- `xchacha20poly1305-*.json`: known-answer tests from the XChaCha20 draft and RustCrypto.
- `vault-v<N>-*.json`: one or more vaults per published format version, with the synthetic password and recovery key that open them.

Rules:

- Never edit or delete a committed vector. A format change adds new files.
- Every secret in this folder is synthetic and documented as such in the file.
- `tests/vectors.rs` loads each file. Add that test together with the first vector.
