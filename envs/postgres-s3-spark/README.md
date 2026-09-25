# Postgres + S3 with Spark *inside* the Airflow container

S3 and Postgres as separate containers, but **no Spark cluster** — PySpark is
installed into the Airflow container itself and jobs run locally in-process.

This is the light variant. Compare
[`postgres-s3-external-spark`](../postgres-s3-external-spark/), which is the
same set of connections against a real standalone Spark cluster. Use this one
when you want the Spark API without paying for two more containers; use the
external one when the job's distribution behaviour actually matters.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow; also runs the Spark job |
| `s3server` | `localstack/localstack:2.1.0` | 4566 | S3-compatible endpoint |
| `postgresdb` | `postgres:13` | 5432 | Target database for the pipeline |

## Setup scripts

- `01_add_connection_s3.sh` — S3 connection, awscli, bucket creation.
- `02_add_connection_postgres.sh` — Postgres connection and target schema.
- `03_add_spark_config.sh` — installs a Temurin JRE, then `pyspark`, the Spark
  and OpenLineage providers, and the Postgres JDBC / `hadoop-aws` /
  `aws-java-sdk-bundle` jars (each checksum-verified).

## Configuration

`SPARK_VERSION=3.5.3`, `DEMO_BUCKET=demo-s3-output`.

## Used by

No example defaults to it. CI runs `spark-s3-to-postgres` against it explicitly:

```bash
cd examples/spark-s3-to-postgres && ../../whirl ci -e postgres-s3-spark
```
