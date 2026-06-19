# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Whirl is a Docker-based local development and testing tool for Apache Airflow workflows. It spins up Airflow with supporting services (S3, databases, Spark, etc.) in Docker containers, allowing developers to run DAGs locally with volume mounts for live code editing.

## Commands

```bash
# Start whirl with current directory as DAG folder
whirl -e <environment> [start]

# Start with a specific example
whirl -x <example> -e <environment>

# Run in CI mode (headless, automated DAG execution)
whirl ci
whirl -x <example> ci

# Stop containers
whirl stop

# View logs
whirl -l
```

The Airflow UI is available at http://localhost:5000 (admin/admin).

## Architecture

### Core Components

- **`whirl`** - Main Bash script (~500 lines) that orchestrates Docker Compose, environment loading, and DAG lifecycle
- **`docker/airflow-python/`** - Airflow Docker image (Dockerfile + entrypoint.sh)
- **`envs/`** - Environment definitions (Docker Compose + setup scripts)
- **`examples/`** - Example DAG projects

### Environment Loading Priority (lowest to highest)

1. `~/.whirl.env`
2. `${SCRIPT_DIR}/.whirl.env` (repository root)
3. `${ENVIRONMENT_FOLDER}/.whirl.env`
4. `${DAG_FOLDER}/.whirl.env`
5. Command-line environment variables

### Key Environment Variables

| Variable | Description |
|----------|-------------|
| `WHIRL_ENVIRONMENT` | Which environment to use (directory name in `envs/`) |
| `AIRFLOW_VERSION` | Airflow version (currently 3.2.1) |
| `PYTHON_VERSION` | Python version (3.10 or 3.13) |
| `DAG_FOLDER` | Path to DAG code (mounted into container) |
| `ENVIRONMENT_FOLDER` | Path to environment definition |

### Setup Scripts

- **`whirl.setup.d/*.sh`** - Executed inside container on startup (install packages, configure connections)
- **`compose.setup.d/*.sh`** - Executed on host before Docker Compose starts

Scripts run in alphabetical order. Environment scripts run before DAG scripts.

## Skills

This repo provides project skills under `.claude/skills/`. Prefer invoking them over performing the equivalent steps manually:

- **create-example** — scaffold a new example in `examples/`. Use for "create/add/scaffold an example".
- **create-environment** — scaffold a new Docker Compose environment in `envs/`. Use for "create/add an environment". Also invoked by `create-example` when a custom environment is needed.
- **version-bumper** — bump `AIRFLOW_VERSION` or `PYTHON_VERSION` across all project files (including the version references in this file).
- **verify-ci-impact** — before committing, map changed files to the examples that need a CI run, then run them after confirming. Use for "what should I test before committing", "which examples does this change affect".

## Agents

Project subagents live under `.claude/agents/`:

- **ci-verifier** — runs the impacted examples in CI mode outside the current session (in the background or as a team member), using the `verify-ci-impact` skill to find what to run. Delegate to it for "verify my changes in the background" or as the verification stage of an agent team. It runs the CI checks autonomously (dispatch = authorization) and returns a pass/fail report.

## Available Environments

Key environments in `envs/`:
- `just-airflow` - Minimal Airflow only
- `api-s3-dataset` - Airflow + S3 + PostgreSQL + MockServer
- `postgres-s3-spark` - Data pipeline with Spark
- `api-python-s3-k8s` - Kubernetes job operators
- `dbt-example` - DBT integration

## CI/Testing

The project uses GitHub Actions with shellcheck for linting. CI runs examples across Python 3.10/3.13 and Airflow 3.2.1.

To test locally:
```bash
# Run CI mode for any example
whirl -x api-to-s3 ci

# Run from example directory
cd examples/api-to-s3 && ../../whirl ci
```

Requires `jq` for CI mode JSON parsing.

## Adding New Examples/Environments

### New Example
Use the **create-example** skill — it gathers requirements interactively and generates all files in `examples/<name>/`.

### New Environment
Use the **create-environment** skill — it gathers requirements interactively and generates all files in `envs/<name>/`.
