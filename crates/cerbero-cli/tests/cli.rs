// SPDX-License-Identifier: AGPL-3.0-only
//! End-to-end tests that run the real `cerbero` binary.
//!
//! Planned here (see `docs/testing.md`): create a vault in a temporary
//! directory, add and read entries, and check that no secret ever reaches
//! stdout or stderr.

use std::process::{Command, Output};

#[allow(
    clippy::expect_used,
    reason = "test helper; failing to start the binary must fail the test"
)]
fn cerbero(args: &[&str]) -> Output {
    Command::new(env!("CARGO_BIN_EXE_cerbero"))
        .args(args)
        .output()
        .expect("the cerbero binary should start")
}

#[test]
fn version_prints_program_and_format_versions() {
    let out = cerbero(&["--version"]);
    assert!(out.status.success());
    let stdout = String::from_utf8(out.stdout).unwrap();
    assert!(
        stdout.starts_with("cerbero "),
        "unexpected output: {stdout}"
    );
    assert!(
        stdout.contains("vault format "),
        "unexpected output: {stdout}"
    );
}

#[test]
fn unknown_command_fails_with_usage_error() {
    let out = cerbero(&["no-such-command"]);
    assert_eq!(out.status.code(), Some(2));
    assert_eq!(String::from_utf8_lossy(&out.stdout), "");
}
