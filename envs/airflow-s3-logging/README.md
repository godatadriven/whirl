# Airflow with remote logging to S3

Airflow configured to write task logs to S3 instead of the local filesystem,
with LocalStack standing in for S3. The DAG itself is beside the point here —
the environment is the subject.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine |
| `s3server` | `localstack/localstack:2.1.0` | 4566 | S3-compatible endpoint holding the log bucket |

## Setup scripts

- `01_add_connection_s3.sh` — adds the `local_s3` connection, installs and
  configures awscli against LocalStack, and creates the log bucket (adding an
  `/etc/hosts` entry so virtual-host-style bucket URLs resolve).
- `02_configure_logging_to_s3.sh` — exports the `AIRFLOW__LOGGING__*` variables
  that switch Airflow over to remote logging.

## Configuration

`S3_LOG_BUCKET=airflow-s3-logs`, with the S3 endpoint at `s3server:4566`.
Remote logging is turned on by the setup script rather than `.whirl.env`, so the
switch happens after the connection it depends on exists.

## Used by

`logging-to-s3`. Open any task log in the UI — the first line states that the
log was fetched from S3.
