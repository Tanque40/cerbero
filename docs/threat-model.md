# Threat model

This document states what Cerbero protects, from whom, and what it does not try to defend against. Every security decision should trace back to it. Update it in the same pull request as any change that adds an asset, an entry point or a trust boundary.

Status: covers phase 1 and 2 (personal vault and CLI). Phase 3 (team server) adds its own section before any server code is written.

## Assets

| Asset | Why it matters |
| ----- | -------------- |
| Vault contents | Passwords, SSH private keys (including legacy RSA keys), RDP credentials and hypervisor console credentials. Disclosure gives direct access to servers and infrastructure. |
| Master password | Unlocks the vault. Often reused habits make it valuable beyond Cerbero. |
| Data key and key-encryption keys | Decrypt the vault without the password. |
| Recovery key | Opens the vault on its own, by design. |
| Vault integrity | A modified vault could plant a wrong host key, a wrong credential or a malicious command. |
| Vault availability | Losing the vault or every way to open it locks the maintainer out of servers. |

## Adversaries and what we defend against

1. **Someone who obtains the encrypted vault file** (stolen laptop, backup, cloud sync, misdirected copy). They must learn nothing except approximate size and format version, and offline guessing of the master password must be expensive. *Defense:* Argon2id with stored, raisable parameters; XChaCha20-Poly1305 with random nonces; authenticated header ([ADR 0002](decisions/0002-own-versioned-vault-format.md), [ADR 0003](decisions/0003-argon2id-and-xchacha20-poly1305.md)).
2. **Someone who modifies the vault file.** Any change must be detected before any plaintext is used. *Defense:* authenticated encryption over entries and header; reject unknown versions and algorithms; no partial decryption output.
3. **Other unprivileged processes and users on the same machine.** They must not read secrets from command-line arguments, environment variables, temporary files, logs or shell history. *Defense:* secrets only from the terminal without echo or from the vault; no secrets in arguments, environment, logs or error messages; restrictive file permissions on the vault ([rules](languages/rust.md#secret-material)).
4. **Leaks through our own software.** Secrets in `Debug` output, panic messages, crash dumps or swap. *Defense:* redacted secret types, `zeroize` on drop, no `unwrap`/`panic` in library code. Swap and crash dumps are reduced, not eliminated (see below).
5. **Compromised or malicious dependencies.** *Defense:* few dependencies, audited RustCrypto crates for primitives, `cargo deny` for advisories, licenses and sources, committed `Cargo.lock`, Dependabot updates reviewed by a person.
6. **Compromised build or CI.** *Defense:* actions pinned by commit SHA, read-only workflow token, no credentials persisted in checkouts, `zizmor` audit of workflows. Signed releases and build provenance are planned before the first release.
7. **Losing access** (forgotten password, lost device). *Defense:* recovery key ([ADR 0004](decisions/0004-recovery-key.md)) and 3-2-1 copies of the encrypted vault.

## Out of scope

Cerbero cannot protect secrets from:

- A machine already compromised by malware running as the user or as root (keyloggers, memory readers, a modified `cerbero` binary). Use dedicated admin workstations for the most sensitive credentials.
- Someone who knows the master password or holds the recovery key.
- Physical attacks on unlocked, running machines (cold boot, DMA).
- Weak master passwords chosen despite warnings. Cerbero will estimate strength and warn, but does not forbid.
- Side channels in hardware or the operating system beyond what the underlying crates mitigate.

## Trust boundaries (phase 1 and 2)

```
 user ──(terminal, no echo)──▶ cerbero-cli ──(bytes)──▶ cerbero-core
                                   │                        │
                                   ▼                        ▼
                         vault file on disk         plaintext only in
                         (always encrypted)         zeroizing memory
                                   │
                                   ▼
                     SSH/RDP clients started by the CLI
                     (receive a credential only for one session)
```

Handing a credential to `ssh`, an RDP client or the clipboard crosses a boundary: after that, the secret is outside Cerbero's control. The CLI design must minimize how long and where it is exposed (for example, an SSH agent with a lifetime instead of writing key files, clipboard clearing with a timeout).

## Open questions

- Clipboard exposure and timeout policy.
- Whether to lock memory pages (`mlock`) and disable core dumps on supported platforms.
- File locking and safe atomic writes for concurrent access to one vault.
