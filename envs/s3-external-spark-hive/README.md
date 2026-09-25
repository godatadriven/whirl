# S3 + Spark + Hive metastore

A Spark cluster with a Hive metastore and a Spark Thrift server, backed by S3.
This is what you want for anything that writes *tables* rather than files —
`saveAsTable`, SQL against a warehouse, dbt-on-Spark.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine |
| `s3server` | `localstack/localstack:2.1.0` | 4566 | S3-compatible endpoint; holds the warehouse |
| `hive` | built locally | 9083 | Hive metastore |
| `sparkmaster` | built locally | 7077, 18080 (UI) | Spark master |
| `sparkworker` | built locally | 18081 (UI) | Spark worker |
| `sparkthrift` | built locally | — | Spark Thrift server (JDBC/SQL access) |

## Setup scripts

- `whirl.setup.d/01_add_connection_s3.sh` — S3 connection, awscli, buckets.
- `whirl.setup.d/03_add_spark_config.sh` — Spark config and the JDBC / S3A jars.
  (There is deliberately no `02_`; the numbering leaves room and the ordering
  contract only requires the `NN_` prefix.)
- `compose.setup.d/01_check_available_memory.sh` — runs **on the host** before
  compose starts and fails early if Docker has too little memory. This stack is
  large enough that it will otherwise die halfway up.
- `compose.setup.d/02_clean_s3_mount_dir.sh` — clears `.s3-mount/` so a previous
  run's warehouse doesn't leak into this one.

## Configuration

`HIVE_DW_BUCKET=demo-hive-dw` is the warehouse location; `DEMO_BUCKET` and
`DBT_BUCKET` are also created. `SPARK_VERSION=3.5.3`.

## Used by

`spark-s3-to-hive` and `dbt-spark-example`. Both are **excluded from CI** — they
need more memory than a GitHub runner has.
