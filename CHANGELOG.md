# Changelog

All notable changes to AI Project Starter are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the kit uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-11-19

### Added

- Generated projects include `CLAUDE.md` (imports `AGENTS.md`), `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1), a `CLA.md` template, `CHANGELOG.md`, `.editorconfig`, issue forms with a private security contact link, a commented `CODEOWNERS`, and `docs/decisions/` with a decision record template.
- Pull request template has a checklist, including CLA agreement.
- `SECURITY.md` in generated projects has supported versions and response sections.
- Kit has `.editorconfig`, `CODE_OF_CONDUCT.md`, this changelog and SPDX headers on its scripts.
- README explains how to use the kit as a GitHub template repository.

### Changed

- CI runs on pushes to `main`, pull requests and manual dispatch, and cancels superseded runs.
- Without-rules evaluation workspaces also omit `CLAUDE.md`.

## [0.2.0]

- Initial public version: project generator, readiness example, optional AGPLv3 license, Dependabot for GitHub Actions and assistant evaluations.
