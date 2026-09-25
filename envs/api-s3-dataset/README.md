# REST API + S3 + Datasets (multi-container Airflow)

Like `api-python-s3`, but Airflow runs as **separate containers per component**
(api-server, scheduler, dag-processor, triggerer) against an external Postgres.
That split is what makes dataset/asset scheduling behave the way it does in a
real deployment, where the scheduler reacting to a dataset update is a
cross-process event rather than an in-process one.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `api-server` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow API server / web UI |
| `scheduler` | same | — | Scheduler |
| `dagprocessor` | same | — | DAG processor |
| `triggerer` | same | — | Triggerer |
| `mockserver` | `mockserver/mockserver:5.15.0` | 1080, 1081 | Fake REST API |
| `postgresdb` | `postgres:16` | 5432 | Airflow metadata database |
| `s3server` | `localstack/localstack:3.0.2` | 4566 | S3-compatible endpoint |

## Setup scripts

- `01_add_connection_api.sh` — waits for the S3 endpoint, then registers the API
  connection.

## Configuration

Airflow's metadata DB is the external `postgresdb` via
`AIRFLOW__DATABASE__SQL_ALCHEMY_CONN`, and the components find each other
through `AIRFLOW__CORE__EXECUTION_API_SERVER_URL=http://api-server:5000/execution`.

## Used by

`airflow-datasets`. That example ships several producer/consumer DAG files
rather than a single `dag.py`, so it has no default DAG for `whirl ci` to pick
and is excluded from the CI matrix.
