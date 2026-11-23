# Decision records

This folder keeps short records of decisions that are expensive to reverse or that a new contributor would otherwise have to rediscover: a data format, a dependency, a security property, a public interface.

## Add a record

1. Copy [`0000-template.md`](0000-template.md) to the next free number, for example `0001-choose-storage-format.md`.
2. Fill it in within the pull request that implements the decision, or in a pull request of its own before that work starts.
3. Set its status to `Accepted` when the pull request merges.

Do not rewrite an accepted record to change the decision. Write a new record, set the old one to `Superseded by NNNN`, and link both ways.

## Index

| No. | Title | Status |
| --- | ----- | ------ |
| [0001](0001-use-rust.md) | Use Rust for the vault and its tools | Accepted |
| [0002](0002-own-versioned-vault-format.md) | Use our own versioned vault format | Accepted |
| [0003](0003-argon2id-and-xchacha20-poly1305.md) | Derive keys with Argon2id and encrypt with XChaCha20-Poly1305 | Accepted |
| [0004](0004-recovery-key.md) | Provide a recovery key from the first version | Accepted |
| [0005](0005-vault-format-v1.md) | Lay out vault format version 1 as one encrypted payload with two key slots | Accepted |
