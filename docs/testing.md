# Testing

`make check` runs every test in the workspace (`cargo test --workspace --all-features --locked`), plus formatting, clippy and cargo-deny. CI runs it on Linux and runs the tests again on macOS.

## Where tests go

| Level | Location | What it proves |
| ----- | -------- | -------------- |
| Unit | `#[cfg(test)] mod tests` at the end of each `src/*.rs` file | Private functions: header parsing, parameter validation, encodings. |
| Integration | `crates/<crate>/tests/*.rs` | Behavior through the public API only. Each file is compiled as a separate crate. |
| Test vectors | `crates/cerbero-core/tests/vectors/` | Fixed inputs and outputs: RFC known-answer tests and sample vaults for each published format version. |
| End-to-end | `crates/cerbero-cli/tests/*.rs` | The real `cerbero` binary: exit codes, output, files in a temporary directory. |
| Property | Inside integration tests, with `proptest` | Invariants over generated inputs, such as decrypt(encrypt(x)) == x and any changed byte is rejected. |
| Fuzzing | `fuzz/`, outside the workspace | Parsers of untrusted bytes never panic or hang. Needs nightly; not part of `make check`. |

Add a dependency such as `proptest`, `tempfile` or `assert_cmd` as a `[dev-dependencies]` entry of the crate that needs it, when the first test uses it.

## Required coverage before vault format 1

- Open a vault with the master password, and with the recovery key alone.
- Changing the master password keeps the recovery key valid.
- Any modified byte in the header or ciphertext is rejected, with no partial plaintext returned.
- Unknown format versions and algorithm identifiers are rejected.
- Known-answer tests for Argon2id and XChaCha20-Poly1305 pass.
- At least one committed sample vault per published format version opens.
- The vault header parser has a fuzz target.
- The CLI never prints a secret to stdout or stderr unless the user asked to reveal it.

## Rules

- Use synthetic secrets only, generated in the test or written as obviously fake constants. Never use a real vault, password or key.
- Keep tests deterministic. Code that needs randomness takes the nonce and salt as parameters in a crate-private function, so vectors can fix them; the public API always draws them from the operating system.
- Use minimal Argon2id parameters in tests to keep them fast. Test production parameters in a separate test marked `#[ignore]`, run with `cargo test -- --ignored`.
- `unwrap`, `expect` and `panic!` are allowed in tests (`clippy.toml`) and nowhere else.
- Every bug fix adds a test that fails without the fix.
- Never edit a committed test vector. A format change adds new vectors.
