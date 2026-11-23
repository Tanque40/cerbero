# Reporting a vulnerability

Cerbero stores passwords, SSH keys and infrastructure credentials, so we treat every report seriously.

Report privately through **Security → Advisories → Report a vulnerability** on [the repository](https://github.com/Tanque40/cerbero/security/advisories/new). Include the affected version or commit, the behavior you observed, and its likely impact. Remove real credentials and personal data from any evidence you share. Do not open a public issue, pull request or discussion about a vulnerability.

## Supported versions

Cerbero has not published a release yet. Only the latest commit on `main` receives security fixes.

| Version | Receives security fixes |
| ------- | ----------------------- |
| `main`  | Yes                     |

## Response

Cerbero is maintained by one person in their spare time. We commit to:

- Acknowledge your report within **7 calendar days**.
- Give an initial assessment (valid or not, and severity) within **14 calendar days**.
- Keep you informed of progress until it is fixed. We do not commit to a fix date, but we prioritize issues that expose vault contents or keys.
- Coordinate disclosure with you, publish a GitHub security advisory once a fix is available, and credit you unless you prefer otherwise.

What counts as a vulnerability is described in the [threat model](docs/threat-model.md), including what is out of scope.
