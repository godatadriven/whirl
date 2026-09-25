# Just Airflow

The minimal environment: a single Airflow container in `singlemachine` mode and
nothing else. Use it when the DAG under test needs no external systems, and as
the starting point when building a new environment.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow web UI, scheduler, dag-processor and triggerer in one container |

## Setup scripts

None. Everything an example needs is added from its own `whirl.setup.d/`.

## Configuration

`.whirl.env` pins `AIRFLOW_VERSION=3.2.1` and disables the bundled example DAGs
and default connections, so only your DAG folder shows up in the UI.

## Used by

`airflow-cluster-policy`, `airflow-deferrable-operator`, `airflow-timetable`.
