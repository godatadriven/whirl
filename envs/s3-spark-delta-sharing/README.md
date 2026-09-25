# Delta Sharing over S3

A Spark cluster writing Delta tables to S3, with a Delta Sharing server in front
of them, so you can test both sides: producing a shared table and reading it
back through the sharing protocol.

This is the reference variant of three. See
[`s3-spark-delta-sharing-minio`](../s3-spark-delta-sharing-minio/) (MinIO
instead of LocalStack) and
[`s3-spark-delta-sharing-riverbank`](../s3-spark-delta-sharing-riverbank/)
(adds a Postgres-backed sharing server).

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine |
| `s3server` | `localstack/localstack:latest` | 4566 | S3-compatible endpoint |
| `delta` | `krisgeus/delta-sharing-server:1.0.0-SNAPSHOT` | 38080 → 8080 | Delta Sharing server |
| `sparkmaster` | built locally | 7077, 18080 (UI) | Spark master |
| `sparkworker` | built locally | 18081 (UI) | Spark worker |
| `sparkshell` | built locally | — | Interactive Spark shell |

## Setup scripts

- `whirl.setup.d/01_add_connection_s3.sh` — S3 connection, awscli, bucket.
- `whirl.setup.d/02_add_spark_config.sh` — Spark config and jars.
- `whirl.setup.d/03_add_delta_config.sh` — Delta and Delta Sharing client config.
- `compose.setup.d/01_check_available_memory.sh` — host-side memory guard.
- `compose.setup.d/02_clean_s3_mount_dir.sh` — clears `.s3-mount/` between runs.

`config/` holds `core-site.xml`, `delta-sharing.yml` and `log4j.properties`,
mounted into the Spark and sharing-server containers.

## Configuration

`SPARK_VERSION=3.5.3`, `DELTA_VERSION=3.3.2`, `DELTA_SHARING_VERSION=1.4.1`.
This environment pins `PYTHON_VERSION=3.11` — the Delta Sharing client does not
yet resolve on the repo default of 3.13.

## Used by

`spark-delta-sharing`. **Excluded from CI** — needs more memory than a GitHub
runner has.
