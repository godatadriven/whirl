# Postgres + S3 + external Spark cluster

S3, Postgres and a standalone Spark cluster (one master, one worker) alongside
Airflow. Jobs are submitted to the cluster rather than run in-process, so this
is the environment to use when you care how a job behaves once it leaves the
scheduler.

Compare [`postgres-s3-spark`](../postgres-s3-spark/), which offers the same
connections with PySpark running inside the Airflow container instead.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine |
| `s3server` | `localstack/localstack:4.0.0` | 4566 | S3-compatible endpoint |
| `postgresdb` | `postgres:17` | 5432 | Target database |
| `sparkmaster` | built locally | 7077, 18080 (UI) | Spark master |
| `sparkworker` | built locally | 18081 (UI) | Spark worker |

## Setup scripts

- `01_add_connection_s3.sh` — S3 connection, awscli, bucket creation.
- `02_add_connection_postgres.sh` — Postgres connection and target schema.
- `03_add_spark_config.sh` — Spark client config plus the Postgres JDBC,
  `hadoop-aws` and `aws-java-sdk-bundle` jars.

## Configuration

`SPARK_VERSION=3.5.3`, `DEMO_BUCKET=demo-s3-output`. The Spark master UI is on
<http://localhost:18080> and the worker on <http://localhost:18081>.

## Used by

`spark-s3-to-postgres` (its default environment).
