#!/bin/sh
# SPDX-License-Identifier: MIT
set -eu

if ! printf 'ready\n' | cmp - public/health.txt; then
    printf '%s\n' 'Expected public/health.txt to contain exactly ready followed by one LF.' >&2
    exit 1
fi
printf '%s\n' 'PASS: public/health.txt matches the expected six bytes.'
