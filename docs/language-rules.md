# Adding language rules

Add a rule when it answers a question a contributor has actually faced. A new file extension alone rarely justifies a style guide. The maintainer of the generated project decides when to adopt, change or retire each rule.

1. **Find the evidence.** Identify the manifest, lockfile, formatter configuration or supported runtime that establishes the choice. For a new choice, get agreement in the change that introduces it.
2. **Enforce what you can.** Configure the chosen tool, give it a check mode and invoke it from the project's verification command. Try a small violation and confirm the check catches it.
3. **Write down the judgment that remains.** If it needs explanation, add a short note in `docs/languages/<language>.md` and link it from the project’s `AGENTS.md`. Name the directories it applies to, the reason for the choice, the source of truth and the command to verify it.
4. **Retire stale advice.** When a tool or runtime changes, update its configuration, check and note together. In a mixed-language project, scope each rule to the package that owns it.

For example, suppose a project adopts a formatter for its first package. Its configuration defines the formatting, the package manifest pins the tool and CI runs it in check mode. The assistant needs to know where those files live and how to run the check. Rewriting each formatting rule in prose gives the team a second copy to maintain.

## When to bring a rule back to the template

Start in the project that needs the rule. Consider contributing an **optional recipe** to this kit when independent projects have used the same approach successfully, the reason applies beyond one codebase, and a minimal example can demonstrate a passing and a failing check. Record its prerequisites and scope. Future projects should opt in deliberately and be free to change it later.

For example, a tested way to fail CI when a runner discovers zero tests can be useful across projects using that runner. A service's decision to retry an internal operation three times belongs with that service. Keep opinions about frameworks, domain models and deployment targets with their owners unless there is evidence for a reusable recipe.
