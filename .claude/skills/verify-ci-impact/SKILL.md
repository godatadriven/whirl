---
name: verify-ci-impact
description: Before committing, work out which Whirl examples need a CI run to verify changes still work, then run them after confirming with the user. Use whenever the user is about to commit and asks "what should I test / verify before committing", "which examples does this change affect", "run CI for what I changed", or wants to validate edits to examples, envs, or core whirl files. Identifies the CI runs first and asks permission before running anything.
---

# Verify CI Impact

When code changes in this repo, only a subset of the ~19 examples actually need
to be re-verified. Running every example is slow (each spins up Docker and an
Airflow run), and running the wrong ones gives false confidence. This skill maps
the changed files to the exact set of examples to verify, presents that plan, and
only runs CI after the user agrees.

The two phases are deliberately separate: **identify first, run second.** Never
start CI runs before the user has seen the plan and approved it — they may want to
narrow the scope, skip the heavy ones, or commit without running anything.

## How impact is determined

The unit of verification is an `(example, environment)` combination, not just an
example. Most examples run against one environment — their **default**, set in
`examples/<name>/.whirl.env` (`WHIRL_ENVIRONMENT=<env>`). But the GitHub Actions
workflow (`.github/workflows/whirl-ci.yml`) also runs a few examples against a
**non-default** environment in separate "extra-env" jobs via `whirl ci -e <env>`
(e.g. `api-to-s3` on `api-python-s3-k8s`, `external-airflow-db` on `ha-scheduler`,
`spark-s3-to-postgres` on `postgres-s3-spark`). Those combinations must be verified
too, so the script parses them straight from the workflow.

The mapping rules (encoded in `scripts/ci_impact.sh`):

| Changed path | Combinations to verify |
|---|---|
| `examples/<name>/...` | `<name>` against **every** env CI runs it with — its default env *and* any non-default extra-env runs |
| `envs/<env>/...` | every `(example, <env>)` combination CI runs, whether `<env>` is that example's default or an extra-env override |
| `whirl`, `docker/...`, `docker-compose.yaml`, root `.whirl.env` | **CORE** — affects all examples; a human picks the scope |
| anything else (`*.md`, `.claude/...`, `README`, logos) | no CI impact |

Both indexes (default from each `.whirl.env`, extra from the workflow) are built
dynamically, so the mapping stays correct as examples are added, re-pointed, or as
extra-env jobs are added/removed. Non-default combinations are tagged
`NON-default` in the output and produce `./whirl -x <example> ci -e <env>` commands.

## Workflow

### 1. Identify the CI runs

Run the bundled script from the repo root:

```bash
.claude/skills/verify-ci-impact/scripts/ci_impact.sh
```

It inspects committed-on-branch changes (vs `master`), staged, unstaged, and
untracked files, then prints: the changed areas, any CORE change, the examples to
verify (with the reason each was selected), and the exact `./whirl -x <example> ci`
commands. Pass `--base <ref>` to diff against a different branch.

Read the output and relay it to the user as a short plan — which examples, and why
each one was selected. Don't just paste the raw output; summarize it.

### 2. Handle the edge cases before asking

- **CORE change** — the script does not expand this to "run everything" because
  that can be 19 Docker runs. Surface it and propose a representative subset (the
  script suggests one covering S3/API, Spark, dbt, DB+SFTP, and just-airflow),
  then let the user decide subset vs. all.
- **Excluded-from-CI examples** — some examples are excluded from the GitHub
  Actions matrix (memory limits, no default DAG, or a separate job): the script
  tags these with a `[NOTE: excluded from GitHub CI matrix]`. They can still be
  run locally, but flag that they need more resources / manual attention and may
  not be part of normal CI.
- **No impact** — if only docs/`.claude/` changed, tell the user no CI run is
  needed and stop. Don't run anything.

### 3. Ask permission

Present the concrete command list and ask the user to confirm before running.
Make the cost visible — note how many runs and that each one builds/starts Docker.
If there are several, ask whether they want all of them, a subset, or to skip.

Only proceed with the runs the user explicitly approves.

### 4. Run the approved CI checks

Run each approved combination in CI mode from the repo root, using the exact
command the script printed — default-env runs are `./whirl -x <example> ci`, and
non-default combinations include the env override:

```bash
./whirl -x <example> ci            # default env
./whirl -x <example> ci -e <env>   # non-default env combination
```

CI mode is headless: it starts the containers, triggers the default DAG, waits for
completion, and tears down. Run them one at a time (they are resource-heavy and
parallel Docker stacks contend for ports/memory). After each run, report whether
the DAG succeeded; if one fails, surface the failure and stop before continuing to
the next unless the user wants to push on.

### 5. Summarize

Report which examples passed, which failed, and which were skipped — so the user
knows exactly what was and wasn't verified before they commit.