# Fuzzing

This folder will hold [cargo-fuzz](https://rust-fuzz.github.io/book/cargo-fuzz.html) targets for every parser that reads untrusted bytes, starting with the vault header. A target passes when no input makes it panic, hang or allocate without bound.

cargo-fuzz needs a nightly toolchain, so this folder stays outside the Cargo workspace and outside `make check`. When the first target is added:

1. Run `cargo fuzz init` here and add `exclude = ["fuzz"]` to `[workspace]` in the root `Cargo.toml`.
2. Commit the targets and a small seed corpus. Do not commit generated corpora or crash artifacts that contain real data.
3. Run locally with `cargo +nightly fuzz run <target>`. A weekly CI job can follow.
