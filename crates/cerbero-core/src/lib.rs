// SPDX-License-Identifier: AGPL-3.0-only
//! Vault format and cryptography for Cerbero.
//!
//! This crate performs no I/O: it receives and returns bytes. Callers own
//! files, terminals and the network. See `docs/languages/rust.md` for the
//! rules that apply to secret material.

#![deny(clippy::print_stdout, clippy::print_stderr)]

/// Version of the on-disk vault format that this build writes.
///
/// Version 0 means "no stable format yet". The first real format will be 1,
/// as described in the decision records under `docs/decisions/`.
pub const FORMAT_VERSION: u16 = 0;

#[cfg(test)]
mod tests {
    use super::FORMAT_VERSION;

    #[test]
    fn format_is_unreleased() {
        assert_eq!(FORMAT_VERSION, 0);
    }
}
