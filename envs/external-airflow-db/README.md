# Airflow against an external metadata database

Multi-container Airflow pointed at a Postgres database running in its own
container, rather than the SQLite database the single-machine setup uses. Use it
to check that a DAG behaves when the metadata DB is remote, and as the base for
the HA scheduler setup.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `api-server` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow API server / web UI |
| `scheduler` | same | — | Scheduler |
| `triggerer` | same | — | Triggerer |
| `dagprocessor` | same | — | DAG processor |
| `postgresdb` | `postgres:13` | 5432 | Airflow metadata database |

## Setup scripts

None.

## Configuration

`AIRFLOW__DATABASE__SQL_ALCHEMY_CONN` is assembled from the `POSTGRES_*`
variables in `.whirl.env`. A fixed `AIRFLOW__CORE__FERNET_KEY` is set so
connection secrets survive a restart.

## Used by

`external-airflow-db`. See also [`ha-scheduler`](../ha-scheduler/), which adds a
second scheduler on top of the same layout.
