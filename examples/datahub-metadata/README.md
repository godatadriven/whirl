#
[Datahub Quickstart Guide](https://datahubproject.io/docs/quickstart)

## Adding metadata

### Postgres

Set `export POSTGRES_PASSWORD=p@ssw0rd`
[Edit this file](./metadata_recipes/postgres_recipe.yaml)
`datahub ingest -c metadata_recipes/postgres_recipe.yaml`

### Airflow

- Follow steps [here](https://datahubproject.io/docs/lineage/airflow), to set up airflow with DataHub, this will allow Airflow to sync metadata with DataHub.
- Add a description to your DAG object

## Looking at metadata
- Airflow
  - See pipeline description and lineage
  - tasks -> see run
  - "View in UI"
