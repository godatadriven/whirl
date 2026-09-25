# Multi-container Airflow with MockServer

Airflow split across one container per component (api-server, scheduler,
dag-processor, triggerer) with an external Postgres, plus a MockServer to
respond to HTTP calls. The split matters for anything that depends on work
actually crossing process boundaries — deferrable operators handing off to the
triggerer, for instance.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `api-server` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow API server / web UI |
| `scheduler` | same | — | Scheduler |
| `dagprocessor` | same | — | DAG processor |
| `triggerer` | same | — | Triggerer; runs deferred tasks |
| `mockserver` | `mockserver/mockserver:5.15.0` | 1080, 1081 | HTTP endpoint the DAG polls |
| `postgresdb` | `postgres:13` | 5432 | Airflow metadata database |

The `build_api` / `build_sched` / `build_trig` / `build_dag` entries are
build-only helpers, not long-running services.

## Setup scripts

None at the environment level; the example supplies its own.

## Used by

`airflow-deferrable-operator-custom`.
