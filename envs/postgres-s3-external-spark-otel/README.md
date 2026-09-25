# Postgres + S3 + Spark with OpenTelemetry tracing

[`postgres-s3-external-spark`](../postgres-s3-external-spark/) plus a full
observability stack: an OpenTelemetry collector receiving traces and metrics,
Tempo storing traces, Prometheus storing metrics, and Grafana on top. This is
the heaviest environment in the repo.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-jre-${OPENJDK_VERSION}-local` | 5000 | Airflow (JRE variant, for `spark-submit`) |
| `s3server` | `localstack/localstack:4.0.0` | 4566 | S3-compatible endpoint |
| `postgresdb` | `postgres:17` | 5432 | Target database |
| `sparkmaster` | built locally | 7077, 18080 (UI) | Spark master |
| `sparkworker` | built locally | 18081 (UI) | Spark worker |
| `otel` | `otel/opentelemetry-collector-contrib` | 4317 (gRPC), 4318 (HTTP), 8888, 8889, 13133, 1888, 55679 | Collector |
| `tempo` | `grafana/tempo:latest` | — | Trace storage |
| `prometheus` | `prom/prometheus:latest` | 9090 | Metric storage |
| `grafana` | `grafana/grafana:latest` | 3000 | Dashboards; anonymous admin, no login form |

`spark_downloads` and `tempo-init` are init helpers, not long-running services.

## Setup scripts

- `01_add_connection_s3.sh` — S3 connection; this is the one place in the repo
  that already uses the robust `curl --fail --retry` wait pattern.
- `02_add_connection_postgres.sh` — Postgres connection and schema.
- `03_add_spark_config.sh` — Spark config and jars, downloaded with
  `curl --progress-bar --connect-timeout 10 --fail`.

## Configuration

`OPENJDK_VERSION=21` selects the JRE-flavoured Airflow image. Grafana's
datasources and Prometheus's scrape config are mounted from the **example's**
`grafana/` folder (`${DAG_FOLDER}/grafana/...`), not from this environment.

## Used by

`spark-opentelemetry`. That example is currently excluded from CI
(`.github/workflows/whirl-ci.yml`, `whirl-ci-opentelemetry-example` is
`if: false`) because it downloads an artifact from
github.com/godatadriven/spot, which has no public Releases yet.
