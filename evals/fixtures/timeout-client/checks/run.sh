#!/bin/sh
# SPDX-License-Identifier: MIT
set -eu

printf 'ready\n' | cmp - public/health.txt
test "$(sh bin/request-deadline.sh)" = unset
test "$(sh bin/request-deadline.sh 7)" = 7
test "$(sh bin/request-deadline.sh 45)" = 45
printf '%s\n' 'PASS: readiness payload, unset deadline by default, and two independent caller-selected deadlines.'
