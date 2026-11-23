#!/bin/sh
# SPDX-License-Identifier: MIT
set -eu

usage() {
    echo 'Usage: sh evals/prepare.sh CASE MODE DEST' >&2
    echo 'Cases: missing-contract, empty-suite, attachment-scope, timeout-fixed, timeout-client' >&2
    echo 'Modes: with-rules, without-rules' >&2
    exit 2
}

[ "$#" -eq 3 ] || usage
case_name=$1
mode=$2
case "$case_name" in
    missing-contract|empty-suite|attachment-scope|timeout-fixed|timeout-client) ;;
    *) usage ;;
esac
case "$mode" in
    with-rules|without-rules) ;;
    *) usage ;;
esac

[ -n "$3" ] || usage
case "$3" in
    /*) destination=$3 ;;
    *) destination=$(pwd)/$3 ;;
esac
if [ -e "$destination" ] || [ -L "$destination" ]; then
    echo "Choose a new destination. The path already exists: $destination" >&2
    exit 1
fi

kit_dir=$(CDPATH= cd -P "$(dirname "$0")/.." && pwd)
fixture_dir=$kit_dir/evals/fixtures
sh "$kit_dir/tools/new-project.sh" --example "$destination"
# From this point on, generation succeeded and this is a new disposable folder.
trap 'rm -rf "$destination"' 0
trap 'exit 1' HUP INT TERM
if [ ! -f "$destination/AGENTS.md" ]; then
    echo 'The generated example must include AGENTS.md for a paired evaluation.' >&2
    exit 1
fi
if [ "$mode" = without-rules ]; then
    # CLAUDE.md only imports AGENTS.md, so it goes too.
    rm "$destination/AGENTS.md"
    rm -f "$destination/CLAUDE.md"
fi

case "$case_name" in
    empty-suite)
        mkdir -p "$destination/qa"
        cp "$fixture_dir/verify.sh" "$destination/qa/verify.sh"
        ;;
    attachment-scope)
        mkdir -p "$destination/attachments"
        cp "$fixture_dir/release-handoff.txt" "$destination/attachments/release-handoff.txt"
        ;;
    timeout-fixed|timeout-client)
        cp -R "$fixture_dir/timeout-common/." "$destination/"
        cp -R "$fixture_dir/$case_name/." "$destination/"
        ;;
esac

trap - 0 HUP INT TERM
printf 'Evaluation workspace: %s\n' "$destination"
