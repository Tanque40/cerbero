# Contributing

Small fixes and documentation corrections are welcome as pull requests. For a change to a public interface or a substantial design decision, open a discussion or issue first so maintainers and users can weigh in. Record decisions that are expensive to reverse in [`docs/decisions/`](docs/decisions/README.md).

1. Fork the repository if you need a place to push, then create a branch for your change.
2. Make the smallest change that addresses the problem. For a behavior change, add or update a check that would catch a regression.
3. Run `make check` and, if you have the tools installed, `make lint`. In the pull request, explain the outcome, what you verified, and any checks you could not run. Describe any user-visible change in the relevant documentation and in [`CHANGELOG.md`](CHANGELOG.md).

Authors are responsible for the changes they submit, including work produced with an AI assistant. Review the diff and verify its claims before asking someone else to review it. Report vulnerabilities using the [security policy](SECURITY.md).

## Commit and pull request titles

Pull requests are squash-merged, so the pull request title becomes the commit on `main`. Write it in the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) form `type(scope): summary`, in English and the imperative mood:

| Type | Use for |
| ---- | ------- |
| `feat` | A new user-visible capability. |
| `fix` | A bug fix. |
| `security` | A fix for a vulnerability or a hardening change. |
| `docs` | Documentation only. |
| `test` | Tests only. |
| `refactor` | Code change with no behavior change. |
| `build` / `ci` | Dependencies, toolchain, CI or repository settings. |
| `chore` | Anything else that does not touch behavior. |

Scopes are `core`, `cli`, `crypto`, `format` or `ci`. Mark a breaking change with `!` after the type, for example `feat(format)!: add vault format 1`, and explain it in the body. A change to the vault format, key derivation or cryptography also needs a decision record.

## Contributor License Agreement

Before maintainers can merge your first pull request, you must agree to the [Contributor License Agreement](CLA.md). It lets the project owner keep distributing the project under its open source license and, if they choose, under other terms. You keep the copyright in your work. The CLA explains how to sign it.

If your employer has rights to what you write, confirm that you have their permission before you contribute.

## Code of conduct

Everyone who participates in this project agrees to follow the [code of conduct](CODE_OF_CONDUCT.md).
