# 0004. Provide a recovery key from the first version

- Status: Accepted
- Date: 2026-11-18
- Deciders: @Tanque40

## Context

If the master password is forgotten, every secret in the vault is lost, including access to servers. The vault holds credentials for production and legacy infrastructure, so losing it is an operational incident.

## Options considered

1. **No recovery.** Simplest, but one forgotten password loses everything.
2. **A recovery key generated at vault creation.** A high-entropy random key, shown once for the user to store offline, that wraps the same data key as the master password.
3. **Shamir secret sharing among several people.** Appropriate for team vaults, excessive for one person.

## Decision

At creation, generate a random recovery key and wrap the vault's data key with it, in addition to the password-derived key. Show it once, encoded for transcription, and never store it in plain text. Recommend 3-2-1 backups of the encrypted vault file. Shamir splitting is deferred to the team phase.

## Consequences

The vault header holds two wrapped copies of the data key. Changing the master password must not invalidate the recovery key, and rotating the recovery key must be possible without re-encrypting entries.

## Verification

None yet. An end-to-end test that opens a vault with only the recovery key will be required before format version 1.
