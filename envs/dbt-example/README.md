# dbt with Postgres and S3

Airflow, Postgres, S3 and a Spark cluster, with dbt installed into the Airflow
container. dbt models run against Postgres; S3 and Spark are there for the
surrounding pipeline.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow; also runs dbt |
| `s3server` | `localstack/localstack:2.1.0` | 4566 | S3-compatible endpoint |
| `postgresdb` | `postgres:13` | 5432 | dbt target database |
| `sparkmaster` | built locally | 7077, 18080 (UI) | Spark master |
| `sparkworker` | built locally | — | Spark worker |

## Setup scripts

- `whirl.setup.d/01_add_connection_s3.sh` — S3 connection, awscli, bucket.
- `whirl.setup.d/02_add_connection_postgres.sh` — Postgres connection and schema.
- `whirl.setup.d/03_add_spark_config.sh` — Spark config and JDBC / S3A jars.
- `whirl.setup.d/04_install_dbt.sh` — installs dbt and the Postgres adapter.
- `compose.setup.d/01_clean_pg_data_dir.sh` — runs **on the host** before compose
  starts, wiping `.pgdata/` so each run begins with an empty database.

## Configuration

`DBT_VERSION=1.10.17`, `DBT_POSTGRES_VERSION=1.9.1`, `SPARK_VERSION=3.5.3`,
`DBT_BUCKET=dbt-s3-output`. dbt logging is set to `debug` in plain text, and
anonymous usage stats are off.

Note the Postgres credentials differ from the Airflow-metadata environments:
user `postgres`, database `postgresdb`.

## Used by

`dbt-example`. It runs as its own CI job rather than in the main matrix, so it
gets a runner to itself.
