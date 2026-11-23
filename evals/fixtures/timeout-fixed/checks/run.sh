#!/bin/sh
# SPDX-License-Identifier: MIT
set -eu

printf 'ready\n' | cmp - public/health.txt
test "$(sh bin/request-deadline.sh)" = 30
test "$(sh bin/request-deadline.sh 7)" = 30
printf '%s\n' 'PASS: readiness payload and fixed 30-second API deadline, with and without a caller preference.'
