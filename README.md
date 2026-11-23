# AI Project Starter

An open-source template for maintainers who use coding assistants and want to review their work. It gives each project one place to record its rules, one command to verify a change, and a way to check whether an assistant's claims match what actually happened.

Version 0.3.0 · [Guía rápida en español](docs/es/guia-rapida.md) · [MIT license](LICENSE)

## Try the example

From the root of a downloaded or cloned copy, run these commands in a POSIX shell. You need `make` and standard Unix utilities on macOS, Linux or WSL. The local checks work offline.

```sh
sh tools/new-project.sh --example ../readiness-demo
make -C ../readiness-demo check
```

The example publishes one file, `public/health.txt`, whose entire contents must be the word `ready` followed by one newline. Its check compares the actual bytes. Try changing the public output, then restoring it.

```sh
printf 'busy\n' > ../readiness-demo/public/health.txt
make -C ../readiness-demo check
# The command above should fail.
printf 'ready\n' > ../readiness-demo/public/health.txt
make -C ../readiness-demo check
```

### Verify the merge gate on GitHub

1. Push the generated example to the default branch of a disposable repository with Actions enabled. Use a repository where you can administer branch protection and where the hosting plan supports it. Run the workflow once so GitHub has observed its job named `check`.
2. On the default branch, require the `check` status from GitHub Actions before merging. For this experiment, use a configuration with no applicable bypass or unrelated approval gate.
3. Create two branches independently from the same default-branch commit. On one branch, improve a sentence in the README. On the other, change `public/health.txt` to `busy` followed by a newline. Open a separate PR for each.
4. Wait for both PR check runs to finish. On the documentation PR, confirm `check` passes and the merge box permits a normal merge. On the regression PR, confirm `check` fails on the byte comparison and the merge box reports that the failed required check prevents merging. Keep both PRs unmerged and record their URLs, head SHAs and check runs as evidence.

## Start your project

```sh
sh tools/new-project.sh ../my-project
```

Choose a new destination outside this kit. Open the **generated directory** as your repository. The generator exports only the project files.

### Using this kit as a GitHub template repository

You can mark the kit's repository as a template, but GitHub's “Use this template” button copies the whole kit, including `tools/`, `evals/` and its own tests. To start a project from it, either:

- **Recommended:** clone the kit, run the generator into a new folder, then push that folder to an empty repository (`git init -b main`, commit, `git remote add origin …`, `git push -u origin main`); or
- use the button to create the repository, then in its clone run `sh tools/new-project.sh ../my-project`, and replace the clone's contents with the generated folder's before your first project commit.

1. Describe the project and its intended users in its README.
2. Replace `checks/run.sh` with a command that exercises real behavior. The blank starter returns an error until you connect that check. Run `make check` and confirm it detects a deliberate regression.
3. Adapt `AGENTS.md`, contribution guidance and the security reporting route to the people who will maintain the project. `CLAUDE.md` only imports `AGENTS.md`; add a similar pointer if another assistant needs one.
4. Fill in the placeholders before publishing: the contact in `CODE_OF_CONDUCT.md`, `[PROJECT NAME]` and `[PROJECT OWNER]` in `CLA.md`, `OWNER/REPO` in `.github/ISSUE_TEMPLATE/config.yml`, the owners in `.github/CODEOWNERS`, and the supported versions in `SECURITY.md`. `grep -rn 'OWNER\|INSERT CONTACT\|PROJECT NAME' .` lists what remains.

Each generated project also includes issue forms, a pull request checklist, `.editorconfig`, a `CHANGELOG.md` and a `docs/decisions/` folder with a decision record template.

The generated files are yours to change. You can replace Make, move the workflow to another CI system, or remove instructions that no longer apply. You decide when to bring in future changes to the kit.

Configure the assistant's actual file, network and credential access in the tool that runs it. The starter's PR workflow grants read access to repository contents and leaves Git credentials out of the checkout. When you publish, verify your private reporting channel and enable any merge protections you want enforced on your host.

Dependabot checks for GitHub Actions version updates weekly in the kit and every exported project. Review each update PR, including the new commit SHA, before merging. Add a package ecosystem to the project's Dependabot configuration when the project adopts it.

## Choose a project license

The kit's original material is [MIT-licensed](LICENSE). Every export preserves that notice in `LICENSES/template-MIT.txt`. The maintainer chooses the terms for their own code before publishing it. A default export leaves that choice open.

Pass a full license text to create the new project's root `LICENSE`. For a project you want to release under AGPLv3 only, the kit includes a copy you can use offline.

```sh
sh tools/new-project.sh --license-file licenses/AGPL-3.0-only.txt ../my-agpl-project
```

Identify your choice in your project README and in notices for your own code, for example `SPDX-License-Identifier: AGPL-3.0-only`. Use `AGPL-3.0-or-later` if you intend to allow later versions. Keep the MIT notice with the inherited material. For another license, supply your own complete text with any required copyright notice.

Each generated project includes a `CLA.md` template, and its contribution guide and pull request checklist ask contributors to agree to it. A CLA keeps the option of offering the project under additional terms, such as a commercial license, alongside its open source license. Adopt it before the first outside contribution is merged, and have the text reviewed by a lawyer before relying on it. If you never plan to relicense, you can replace it with the lighter [Developer Certificate of Origin](https://developercertificate.org/) or remove it.

The bundled [AGPLv3 license document](licenses/AGPL-3.0-only.txt) is reproduced verbatim from the [SPDX License List](https://spdx.org/licenses/AGPL-3.0-only.html) under the Free Software Foundation's permission to copy the text.

## Evaluate an assistant

The exercises cover a missing interface, a reporter that ran zero tests, an instruction inside an attachment and two conflicting accounts of an API timeout. The timeout exercise asks the same question in four fresh projects, with two underlying contracts and two instruction conditions. The evaluator keeps the scoring guide and previous replies outside each assistant's workspace. [Prompts and setup](evals/README.md)

## Add a language when you adopt it

The shell scripts are the kit's test harness. Your application can use any language. Introduce a rule in the project that needs it, record where the choice is implemented, and connect its check to CI. Promote a proven practice to an optional template recipe when other projects can reproduce its benefit. [Language rules guide](docs/language-rules.md)

## Work on the template

Edit `starter/` to change newly generated projects and `examples/readiness/` to change the example. Run `make check` here to test generation, the example's failure and recovery, and the evaluation fixtures. Assistant behavior is scored separately in a live session. Small fixes can go directly to a pull request. Include the command you ran and what it demonstrated.

For a suspected vulnerability, use the [security policy](SECURITY.md).
