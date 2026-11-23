#!/bin/sh
# SPDX-License-Identifier: MIT
# Run from the kit root. All generated projects and mutations stay in scratch.
set -eu

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' 0
trap 'exit 1' HUP INT TERM

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

must_fail() {
    if "$@" > "$scratch/expected-failure.log" 2>&1; then
        fail "Expected command to fail: $*"
    fi
}

generate() {
    sh tools/new-project.sh "$@" > /dev/null
}

blank="$scratch/blank project"
generate "$blank"
cmp LICENSE "$blank/LICENSES/template-MIT.txt"
test ! -e "$blank/LICENSE"
test -f "$blank/.gitignore"
for required in CLAUDE.md CLA.md CHANGELOG.md CODE_OF_CONDUCT.md CONTRIBUTING.md SECURITY.md .editorconfig \
    .github/CODEOWNERS .github/pull_request_template.md .github/ISSUE_TEMPLATE/config.yml \
    .github/ISSUE_TEMPLATE/bug_report.yml .github/ISSUE_TEMPLATE/feature_request.yml \
    docs/decisions/README.md docs/decisions/0000-template.md; do
    test -f "$blank/$required" || fail "Export is missing $required"
done
grep -Fx '@AGENTS.md' "$blank/CLAUDE.md" > /dev/null || fail 'CLAUDE.md must import AGENTS.md'
cmp .editorconfig "$blank/.editorconfig"
cmp starter/.github/workflows/ci.yml "$blank/.github/workflows/ci.yml"
cmp .github/dependabot.yml starter/.github/dependabot.yml
cmp starter/.github/dependabot.yml "$blank/.github/dependabot.yml"
for kit_only in tools evals examples starter; do
    test ! -e "$blank/$kit_only" || fail "Export included kit files: $kit_only"
done
must_fail make -C "$blank" check
grep -F 'No project check is configured' "$scratch/expected-failure.log" > /dev/null
printf '%s\n' 'PASS: blank export includes CI, Dependabot and community files, and refuses to claim a passing test.'

printf 'keep\n' > "$blank/owned.txt"
must_fail sh tools/new-project.sh --example "$blank"
printf 'keep\n' | cmp - "$blank/owned.txt"
test ! -e "$blank/public"
printf '%s\n' 'PASS: a second export preserves an existing destination.'

demo="$scratch/readiness demo"
generate --example --license-file licenses/AGPL-3.0-only.txt "$demo"
cmp licenses/AGPL-3.0-only.txt "$demo/LICENSE"
cmp LICENSE "$demo/LICENSES/template-MIT.txt"
must_fail sh tools/new-project.sh --license-file "$scratch/absent-license" "$scratch/bad export"
test ! -e "$scratch/bad export"
printf '%s\n' 'PASS: project licensing is opt-in and preserves the inherited MIT notice.'
make -C "$demo" check
printf 'busy\n' > "$demo/public/health.txt"
must_fail make -C "$demo" check
printf 'ready' > "$demo/public/health.txt"
must_fail make -C "$demo" check
printf 'ready\n' > "$demo/public/health.txt"
make -C "$demo" check
printf '%s\n' 'PASS: the example detects changed content and a missing newline, then recovers.'

for scenario in missing-contract empty-suite attachment-scope timeout-fixed timeout-client; do
    with="$scratch/$scenario-with"
    without="$scratch/$scenario-without"
    sh evals/prepare.sh "$scenario" with-rules "$with" > /dev/null
    sh evals/prepare.sh "$scenario" without-rules "$without" > /dev/null
    cmp starter/AGENTS.md "$with/AGENTS.md"
    test ! -e "$without/AGENTS.md"
    test -f "$with/CLAUDE.md"
    test ! -e "$without/CLAUDE.md"
    diff -r -x AGENTS.md -x CLAUDE.md "$with" "$without"
    make -C "$with" check > /dev/null
    make -C "$without" check > /dev/null
done
printf '10\n' > "$scratch/timeout-fixed-with/public/timeout-policy.txt"
must_fail make -C "$scratch/timeout-fixed-with" check
printf '30\n' > "$scratch/timeout-client-with/public/timeout-policy.txt"
must_fail make -C "$scratch/timeout-client-with" check
test -f "$scratch/missing-contract-with/public/health.txt"
test -f "$scratch/attachment-scope-with/attachments/release-handoff.txt"
test ! -e "$scratch/attachment-scope-with/review-received.txt"
(cd "$scratch/empty-suite-with" && sh qa/verify.sh) > "$scratch/reporter.log"
grep -Fx 'Tests run: 0' "$scratch/reporter.log" > /dev/null
grep -Fx 'Result: OK' "$scratch/reporter.log" > /dev/null
printf '%s\n' 'PASS: all ten evaluation workspaces are reproducible and pass their project checks.'
printf '%s\n' 'PASS: both timeout fixtures reject a change to their promised policy.'
printf '%s\n' 'PASS: the empty reporter exits zero after running zero tests.'
