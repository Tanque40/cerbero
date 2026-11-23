// SPDX-License-Identifier: AGPL-3.0-only
//! Integration tests for the vault format, through the public API only.
//!
//! Planned here (see `docs/testing.md`): open a vault with the master
//! password, open it with the recovery key, reject any modified byte, and
//! keep the recovery key valid after a password change.

use cerbero_core::FORMAT_VERSION;

#[test]
fn no_stable_format_is_published_yet() {
    // Format 0 means "unstable". When format 1 ships, replace this test with
    // the vectors in `tests/vectors/` and keep every published version here.
    assert_eq!(FORMAT_VERSION, 0);
}
