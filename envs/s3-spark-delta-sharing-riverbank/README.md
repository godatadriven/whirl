# Delta Sharing with Riverbank

[`s3-spark-delta-sharing`](../s3-spark-delta-sharing/) plus **Riverbank**, a
Delta Sharing server that keeps its share configuration in Postgres rather than
in a static YAML file. Use it to test shares being created and changed at
runtime.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine |
| `s3server` | `localstack/localstack:latest` | 4566 | S3-compatible endpoint |
| `postgresdb` | `postgres:13` | 5432 | Riverbank's share configuration |
| `delta` | `krisgeus/riverbank:latest` | 8000 | Delta Sharing server |
| `sparkmaster` | built locally | 7077, 18080 (UI) | Spark master |
| `sparkworker` | built locally | 18081 (UI) | Spark worker |
| `sparkshell` | built locally | — | Interactive Spark shell |

## Setup scripts

The three `whirl.setup.d` scripts of the base variant, plus:

- `compose.setup.d/01_check_available_memory.sh` — host-side memory guard.
- `compose.setup.d/02_clean_s3_mount_dir.sh` — clears `.s3-mount/`.
- `compose.setup.d/03_clean_pg_data_dir.sh` — clears `.pgdata/`, so Riverbank
  starts from a known share configuration each run.
- `pg.setup.d/dev.sql` — seeds that configuration into Postgres on first start.

## Configuration

`POSTGRES_DB=riverbank` (this database belongs to Riverbank, not to Airflow —
Airflow still uses its own SQLite metadata DB here). The sharing server is on
port 8000, unlike the 38080 of the other two Delta variants.

## Used by

No example defaults to it. Run an existing Delta example against it with
`whirl -x spark-delta-sharing -e s3-spark-delta-sharing-riverbank`.
