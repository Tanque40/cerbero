.PHONY: check lint

# Formatting, clippy, tests and cargo-deny. Required to merge.
check:
	sh checks/run.sh

# Extra linters: spelling, workflow security and unused dependencies.
lint:
	sh checks/lint.sh
