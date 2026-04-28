---
name: version-bumper
description: Bump the Airflow or Python version across all project files. Use when the user wants to update AIRFLOW_VERSION or PYTHON_VERSION.
argument-hint: "[airflow|python] <new-version>"
disable-model-invocation: false
---

Bump a version across all relevant files in the whirl project.

## Instructions

The user will specify which version to bump (`airflow` or `python`) and the new version number.

If the version type or target version is unclear, ask the user before proceeding.

## File types to search

The version string appears as a hardcoded literal (not a shell variable reference like `${AIRFLOW_VERSION}`) in these file types:

- `**/.whirl.env` — as `AIRFLOW_VERSION=<version>` or `PYTHON_VERSION=<version>`
- `**/Dockerfile` and `**/Dockerfile.*` — as `ARG AIRFLOW_VERSION=<version>` or `ARG PYTHON_VERSION=<version>`
- `**/*.yml` — as `airflow_version: ["<version>"]` or in `python_version: [...]` lists
- `CLAUDE.md` — as prose references to the current version

## Steps

1. **Discover the current version** by searching for the literal version pattern across the relevant file types:
   ```
   # For AIRFLOW_VERSION
   grep -rn "AIRFLOW_VERSION=[0-9]" --include="*.env" --include="Dockerfile*" .
   grep -rn "airflow_version:" --include="*.yml" .
   grep -rn "AIRFLOW_VERSION" CLAUDE.md

   # For PYTHON_VERSION
   grep -rn "PYTHON_VERSION=[0-9]" --include="*.env" --include="Dockerfile*" .
   grep -rn "python_version:" --include="*.yml" .
   ```
   This reveals the current version and every file that needs updating.

2. **Exclude false positives** — skip matches where the version is a shell variable reference (e.g. `${AIRFLOW_VERSION}`) or a minimum-version guard (`MINIMAL_AIRFLOW_VERSION`). These must not be changed.

3. **Edit each matched file** using the Edit tool, replacing the old version string with the new one. Use `replace_all: true` for files where the string appears multiple times (e.g. Dockerfiles with two `ARG` lines, CI workflows with multiple matrix blocks).

4. **Verify** by re-running the discovery grep from step 1 and confirming no occurrences of the old version remain:
   ```
   grep -rn "<old-version>" --include="*.env" --include="Dockerfile*" --include="*.yml" .
   grep -n "<old-version>" CLAUDE.md
   ```

5. **Report** which files were changed and the new version value in each.

6. **Check docker-compose changes** against the official Airflow release (Airflow version bumps only):

   Fetch the official docker-compose for the new version:
   ```
   curl -Lf 'https://airflow.apache.org/docs/apache-airflow/<NEW_VERSION>/docker-compose.yaml'
   ```

   Then read each `envs/*/docker-compose.yml` in this repo and compare the Airflow service definitions (api-server, scheduler, dagprocessor, triggerer) against the official file. Focus on:
   - New or removed environment variables in the `x-airflow-common` block
   - New or removed volume mounts
   - Changed healthcheck commands or intervals
   - Changed service dependencies (`depends_on`)
   - Changed ports or commands

   **Known intentional differences to ignore** — these are whirl-specific and must NOT be "fixed":

   | Topic | Official docker-compose | Whirl envs |
   |-------|------------------------|------------|
   | Image | `apache/airflow:<version>` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` |
   | Port | api-server on `8080` | api-server on `5000` (with `-p 5000` command arg) |
   | Executor | `CeleryExecutor` with worker + Redis | No executor set (uses LocalExecutor via `.whirl.env`) |
   | Env vars (official only) | `AIRFLOW__CORE__EXECUTOR`, `AIRFLOW__DATABASE__SQL_ALCHEMY_CONN`, `AIRFLOW__CELERY__*`, `AIRFLOW__CORE__FERNET_KEY`, `AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION`, `AIRFLOW__CORE__LOAD_EXAMPLES`, `AIRFLOW_CONFIG`, `_PIP_ADDITIONAL_REQUIREMENTS` | Sourced from `.whirl.env` via `env_file` |
   | Env vars (whirl only) | — | `WHIRL_SETUP_FOLDER`, `AIRFLOW__FAB__AUTH_BACKENDS`, `AIRFLOW__API_AUTH__JWT_SECRET` |
   | Volume mounts (official only) | `logs/`, `config/`, `plugins/` directories | Not mounted |
   | Volume mounts (whirl only) | — | `whirl.setup.d` → `env.d/` and `dag.d/`, `src/` + `setup.py` → `/opt/airflow/custom/`, named build volumes per service |
   | Init service | `airflow-init` for DB migration + user creation | Handled by whirl entrypoint scripts |
   | Restart policy | `restart: always` | Not set |
   | User | `"${AIRFLOW_UID:-50000}:0"` | Not set |

   **Report any differences that are NOT in the table above** — those may indicate new config or behaviour in the Airflow release that should be adopted in the whirl envs.