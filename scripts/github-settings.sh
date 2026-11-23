#!/bin/sh
# SPDX-License-Identifier: AGPL-3.0-only
# Apply Cerbero's repository settings with the GitHub CLI.
# Usage: sh scripts/github-settings.sh [OWNER/REPO]   (needs `gh auth login` as a repo admin)
# Safe to run again: it updates the same settings and replaces the ruleset named "main".
set -eu

repo="${1:-Tanque40/cerbero}"
api() { gh api -H "Accept: application/vnd.github+json" "$@"; }

echo "Merge settings: squash only, PR title as commit, delete merged branches"
api -X PATCH "repos/$repo" \
    -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
    -F delete_branch_on_merge=true -F allow_update_branch=true \
    -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
    -F has_wiki=false >/dev/null

echo "Security: secret scanning, push protection, Dependabot alerts and fixes, private reporting"
api -X PATCH "repos/$repo" --input - >/dev/null <<'JSON'
{"security_and_analysis": {
  "secret_scanning": {"status": "enabled"},
  "secret_scanning_push_protection": {"status": "enabled"}}}
JSON
api -X PUT "repos/$repo/vulnerability-alerts" >/dev/null
api -X PUT "repos/$repo/automated-security-fixes" >/dev/null
api -X PUT "repos/$repo/private-vulnerability-reporting" >/dev/null

echo "Actions: read-only token, workflows cannot approve pull requests"
api -X PUT "repos/$repo/actions/permissions/workflow" \
    -f default_workflow_permissions=read -F can_approve_pull_request_reviews=false >/dev/null

echo "Ruleset on the default branch"
ruleset='{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}},
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "required_linear_history"},
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": true,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": true,
      "allowed_merge_methods": ["squash"]}},
    {"type": "required_status_checks", "parameters": {
      "strict_required_status_checks_policy": true,
      "required_status_checks": [
        {"context": "check", "integration_id": 15368},
        {"context": "lint", "integration_id": 15368},
        {"context": "test-macos", "integration_id": 15368}]}}
  ]
}'
existing=$(api "repos/$repo/rulesets" --jq '.[] | select(.name == "main") | .id')
if [ -n "$existing" ]; then
    printf '%s' "$ruleset" | api -X PUT "repos/$repo/rulesets/$existing" --input - >/dev/null
else
    printf '%s' "$ruleset" | api -X POST "repos/$repo/rulesets" --input - >/dev/null
fi

echo "Done. Review at https://github.com/$repo/settings"
