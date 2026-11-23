// SPDX-License-Identifier: AGPL-3.0-only
//! `cerbero` command-line interface.

use std::process::ExitCode;

fn main() -> ExitCode {
    if let Some("--version" | "-V") = std::env::args().nth(1).as_deref() {
        println!(
            "cerbero {} (vault format {})",
            env!("CARGO_PKG_VERSION"),
            cerbero_core::FORMAT_VERSION
        );
        ExitCode::SUCCESS
    } else {
        eprintln!("cerbero: no commands yet. Try `cerbero --version`.");
        ExitCode::from(2)
    }
}
