# Delta Sharing over MinIO

The same shape as [`s3-spark-delta-sharing`](../s3-spark-delta-sharing/), but
with **MinIO** as the object store instead of LocalStack. Worth reaching for when
you suspect a problem is LocalStack-specific, or when you need behaviour closer
to a real S3 implementation.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine |
| `s3server` | `minio/minio:RELEASE.2023-06-19T19-52-50Z` | 9000 | MinIO object store |
| `delta` | `krisgeus/delta-sharing-server:1.0.0-SNAPSHOT` | 38080 → 8080 | Delta Sharing server |
| `sparkmaster` | built locally | 7077, 18080 (UI) | Spark master |
| `sparkworker` | built locally | 18081 (UI) | Spark worker |
| `sparkshell` | built locally | — | Interactive Spark shell |

## Setup scripts

Same four as the LocalStack variant, plus the two host-side `compose.setup.d`
scripts. The S3 readiness check differs: MinIO is polled on
`/minio/health/live` rather than on the bucket endpoint.

## Configuration

`AWS_PORT=9000` (MinIO's port, not 4566) and MinIO-style credentials.
`SPARK_VERSION=3.5.3`, `DELTA_VERSION=2.4.0`, `DELTA_SHARING_VERSION=0.7.0` —
note the older Delta versions compared with the LocalStack variant.

## Used by

No example defaults to it. Run an existing Delta example against it with
`whirl -x spark-delta-sharing -e s3-spark-delta-sharing-minio`.
