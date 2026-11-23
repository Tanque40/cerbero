#!/bin/sh
# SPDX-License-Identifier: MIT
# A test reporter at the end of an empty discovery run.
set -eu
printf '%s\n' 'Discovery finished' 'Tests run: 0' 'Failures: 0' 'Result: OK'
exit 0
