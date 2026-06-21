# Contributing to Whirl

Thanks for your interest in contributing to _whirl_! This document describes how
to propose changes and what we expect from a contribution.

## Ways to contribute

- **Report a bug** — open a [GitHub issue](https://github.com/godatadriven/whirl/issues)
  describing what you did, what you expected and what actually happened. Include
  your OS, Docker version, the example/environment used and relevant log output.
- **Suggest an improvement** — open an issue to discuss larger changes before
  you start, so we can agree on the approach.
- **Add an example or environment** — see [Adding examples and environments](#adding-examples-and-environments).
- **Improve documentation** — README, example READMEs and inline comments are
  all fair game.

## Development workflow

1. Fork the repository and create a feature branch off `master`
   (e.g. `git checkout -b my-improvement`).
2. Make your change in small, focused commits with descriptive messages.
3. Make sure your change passes the checks described in [Testing](#testing).
4. Open a pull request against `master` describing **what** changed and **why**.
   Link any related issue.

### Pull request expectations

- Keep PRs focused: one logical change per PR is much easier to review.
- Update documentation (README / example README) when behaviour changes.
- If you change the main `whirl` script, an environment or an example, list the
  examples you ran to verify the change in the PR description.
- CI must be green before a PR can be merged.

## Shell script style guide

The main `whirl` script and the setup scripts under `whirl.setup.d/` and
`compose.setup.d/` are Bash. Please follow these conventions:

- Start scripts with `#!/usr/bin/env bash`.
- Add `set -e` (and where appropriate `set -euo pipefail`) so failures stop the
  script instead of silently continuing.
- **Quote your variables**: `"${VAR}"`, not `$VAR`, especially for paths.
- Prefer functions for repeated logic over copy-pasting (e.g. reuse the
  `airflow_api` helper in `whirl` instead of hand-writing `curl` calls).
- All shell code must pass [`shellcheck`](https://www.shellcheck.net/). CI runs
  `shellcheck -x whirl`; run it locally before pushing:

  ```bash
  shellcheck -x whirl
  shellcheck examples/**/whirl.setup.d/*.sh
  ```

- When you intentionally ignore a `shellcheck` finding, add a
  `# shellcheck disable=SCXXXX` comment explaining why.

## Testing

There are two complementary layers of testing.

### Unit tests (fast, no Docker)

A [pytest](https://docs.pytest.org/) suite under `tests/` gives quick feedback
without booting any containers. It is managed with [uv](https://docs.astral.sh/uv/)
and runs on Python 3.13 (the newest version Airflow 3.2.1 supports). The `test`
dependency group installs Airflow and the providers needed to parse the example
DAGs.

```bash
# One-time: install uv (https://docs.astral.sh/uv/getting-started/installation/)
uv python install 3.13
uv sync --group test    # creates .venv and installs the test toolchain

# Run the suite
uv run pytest

# Run only one layer
uv run pytest tests/test_dag_validation.py   # example DAGs parse cleanly
uv run pytest tests/test_setup_scripts.py    # setup-script conventions
```

The same suite runs in CI as the `unit-tests` job. Add a unit test when you add
or change behaviour that can be checked without a running Airflow.

### End-to-end (CI mode, requires Docker)

The deeper verification runs examples end-to-end: it builds the Docker image,
starts the environment, triggers the DAG and asserts it succeeds.

```bash
# Run a single example headless (requires Docker and jq)
whirl -x api-to-s3 ci

# Or from inside an example directory
cd examples/api-to-s3 && ../../whirl ci
```

Run the examples affected by your change before opening a PR. If you use the
Claude Code skills bundled in this repo, the `verify-ci-impact` skill maps your
changed files to the examples that need a CI run.

## Adding examples and environments

- New examples live under `examples/<name>/` and should include a `dag.py`, a
  `.whirl.env` and a `README.md` describing what the example demonstrates and
  how to run it.
- New environments live under `envs/<name>/` and contain a `docker-compose.yml`,
  a `.whirl.env` and any `whirl.setup.d/` scripts.
- The repo ships Claude Code skills (`create-example`, `create-environment`)
  that scaffold these for you — see [CLAUDE.md](CLAUDE.md).

## License

By contributing, you agree that your contributions will be licensed under the
[Apache License 2.0](LICENSE), the same license that covers this project.