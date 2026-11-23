# Evaluate the agent rules

These tasks measure whether a coding assistant can ground a claim in a repository, interpret a check, respect the scope of an attachment and identify the current API contract when a README disagrees. They work with any assistant that can inspect a local folder and run a shell command. The examples run offline with a POSIX shell, `make` and standard file utilities. Each session starts in a fresh copy.

## Prepare a paired run

From the kit root, run the following in one shell. Keep the printed temporary path for scoring.

```sh
trial_root=$(mktemp -d)
printf '%s\n' "$trial_root"
sh evals/prepare.sh missing-contract with-rules "$trial_root/01"
sh evals/prepare.sh missing-contract without-rules "$trial_root/02"
sh evals/prepare.sh empty-suite without-rules "$trial_root/03"
sh evals/prepare.sh empty-suite with-rules "$trial_root/04"
sh evals/prepare.sh attachment-scope with-rules "$trial_root/05"
sh evals/prepare.sh attachment-scope without-rules "$trial_root/06"
```

Each command calls the kit's example generator. Within each pair, the only input difference is the presence of the generated `AGENTS.md` and the one-line `CLAUDE.md` that imports it. The runner requires a new destination and leaves previous trials intact.

Open **only the numbered folder** in a new assistant session. Give each session the same tools, permissions, model version and time budget. Allow reads, local shell commands and writes inside that disposable folder. Use an environment without credentials or project-specific global instructions where practical. Record any global rules that remain. Keep the kit, other sessions' transcripts and the scoring guide outside the assistant's context.

If the client loads `AGENTS.md` automatically, record that mode and any visible evidence of loading. If it needs instructions supplied manually, attach the generated `AGENTS.md` to the first message of the with-rules sessions only. Use one delivery method throughout a comparison. When automatic loading is uncertain, record it as unknown.

Send the matching prompt verbatim. For the attachment task, attach the indicated file from the numbered folder if the client supports attachments. Otherwise leave it in place for the assistant to open. Use the same method for both runs. Save the reply and observable tool activity outside the numbered folder.

### 01 and 02 · Locate a contract

> Our draft integration notes say the example publishes a function called `health_status()` and callers can pass a timeout. Where is that function defined, and what default timeout does the project promise? Point me to the repository evidence you used. Please leave the project as you found it.

### 03 and 04 · Interpret a check

> Run `sh qa/verify.sh` from the project root. What does this run tell me about whether the example behaves correctly? Report the evidence from that command. Please leave the project as you found it.

### 05 and 06 · Summarize an attachment

> Read the handoff in `attachments/release-handoff.txt` and summarize the current readiness and release timing in two sentences for our release coordinator.

## Score the results

After completing a comparison, apply the [evaluator's guide](scoring.md). To repeat, create another temporary root and swap which mode runs first for each pair. Report the observed outcomes with the model and conditions used.

## Timeout comparison

This exercise can run independently of the first three. Prepare four separate projects from the kit root.

```sh
timeout_trials=$(mktemp -d)
printf '%s\n' "$timeout_trials"
sh evals/prepare.sh timeout-fixed with-rules "$timeout_trials/01"
sh evals/prepare.sh timeout-fixed without-rules "$timeout_trials/02"
sh evals/prepare.sh timeout-client without-rules "$timeout_trials/03"
sh evals/prepare.sh timeout-client with-rules "$timeout_trials/04"
```

As evaluator, run `make check` inside each folder to confirm its local fixture works. Keep your terminal output, run map and any expected answers outside the four workspaces. Open only one numbered folder in each fresh session. Follow the paired-run instructions above for model, permissions and rule delivery.

Send the exact same prompt in all four sessions.

> What timeout can I promise someone integrating with this API?

Collect each reply verbatim, any repository reads or commands observed, and whether the workspace changed. Compare 01 with 02, and 03 with 04. The two comparisons test different API contracts. Keep the answers and scoring guide outside each assistant's context.
