#!/bin/sh
# SPDX-License-Identifier: MIT
# Print the effective request deadline in seconds, or "unset" if none is set.
# Run from the project root. An optional argument is the caller's deadline.
set -eu

if [ "$#" -gt 1 ]; then
    echo 'Usage: sh bin/request-deadline.sh [positive-seconds]' >&2
    exit 2
fi
if [ "$#" -eq 1 ]; then
    case "$1" in
        ''|0*|*[!0-9]*) echo 'Expected a positive integer.' >&2; exit 2 ;;
    esac
fi

policy=$(cat public/timeout-policy.txt)
case "$policy" in
    caller) printf '%s\n' "${1-unset}" ;;
    ''|0*|*[!0-9]*) echo 'Invalid timeout policy.' >&2; exit 1 ;;
    *) printf '%s\n' "$policy" ;;
esac
