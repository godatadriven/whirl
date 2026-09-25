# REST API to S3

A mock REST endpoint plus an S3-compatible store: the classic "pull from an API,
land it in object storage" shape, with no database involved.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine |
| `mockserver` | `mockserver/mockserver:5.15.0` | 1080, 1081 | Serves the fake API the DAG reads from |
| `s3server` | `localstack/localstack:2.1.0` | 4566 | S3-compatible endpoint |

## Setup scripts

- `01_add_connection_s3server.sh` — adds the S3 connection, configures awscli
  against LocalStack and creates `DEMO_BUCKET`.

The MockServer expectations come from the *example*, not from here — see the
example's own `whirl.setup.d/`.

## Configuration

`DEMO_BUCKET=demo-s3-output`, S3 at `s3server:4566`.

## Used by

`api-to-s3` (its default environment).
