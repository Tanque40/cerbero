# Project workspace

Replace this introduction with the project name, the problem it solves, and a working example for the people who will use it. All files in this workspace are yours to adapt.

## Run the checks

Run the following command from the repository root.

```sh
make check
```

This runs `sh checks/run.sh`. In a fresh workspace the command fails until you connect a real check. Edit the script to exercise one behavior that matters to your project and return a nonzero exit status when it fails. Change the behavior once and confirm the check catches the change.

## Working together

See the [contribution guide](CONTRIBUTING.md), [Contributor License Agreement](CLA.md), [code of conduct](CODE_OF_CONDUCT.md), [security reporting policy](SECURITY.md), [decision records](docs/decisions/README.md) and [instructions for AI assistants](AGENTS.md). `CLAUDE.md` imports the same instructions. Before publishing, document how to run the project, verify a private security contact and replace the placeholders: `grep -rn 'OWNER\|INSERT CONTACT\|PROJECT NAME' .`

## Licensing

Files inherited from the starter carry the MIT notice in `LICENSES/template-MIT.txt`. Keep that notice with the portions you retain. Before publishing or distributing the project, explicitly choose a license for your own additions. You could choose `AGPL-3.0-only` for those additions while preserving the MIT notice for reused material.

The generator copies your chosen license to the root `LICENSE` only when you pass `--license-file`. Otherwise, add the file yourself. Document which license covers each part of the project.
