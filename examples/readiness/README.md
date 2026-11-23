# Readiness file example

A client that reads `public/health.txt` expects the five ASCII letters `ready` followed by a single line feed (LF).

Run the acceptance check from the project root.

```sh
make check
```

The check compares the file byte for byte with the expected response. Try adding a second line and rerunning it. Restore the original six bytes and rerun the check to see it pass again.

See `CONTRIBUTING.md` for contribution instructions and `SECURITY.md` for private reporting guidance.

## Licensing

The starter and example files carry the MIT notice in `LICENSES/template-MIT.txt`. Keep it with the portions you reuse. Before publishing or distributing your version, explicitly choose a license for your own additions. For example, you may choose `AGPL-3.0-only` for those additions and preserve the MIT notice for the inherited files.

Passing `--license-file` to the generator places your chosen license in the root `LICENSE`. Otherwise, add that file yourself and document the scope of your choice.
