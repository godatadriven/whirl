# Highly-available scheduler (two schedulers)

The same layout as [`external-airflow-db`](../external-airflow-db/), but with
**two scheduler containers** running against one Postgres metadata database.
Airflow's schedulers coordinate through row-level locks in that database, so
this is the smallest setup where you can watch them share work — and where a
DAG that quietly assumes a single scheduler will show it.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `api-server` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow API server / web UI |
| `scheduler1` | same | — | First scheduler |
| `scheduler2` | same | — | Second scheduler |
| `dagprocessor` | same | — | DAG processor |
| `postgresdb` | `postgres:13` | 5432 | Shared metadata database |

## Setup scripts

None.

## Used by

No example defaults to it. It is exercised in CI by running the
`external-airflow-db` example against it explicitly:

```bash
cd examples/external-airflow-db && ../../whirl ci -e ha-scheduler
```
