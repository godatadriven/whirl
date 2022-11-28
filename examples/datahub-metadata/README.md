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
- Run airflow DAG

### dbt

1. Move cli to dbt directory
2. `export DBT_PROFILES_DIR=$(pwd)`
3. `dbt run`
4. `dbt docs generate`
5. `dbt test`, run this last, so the test results are shown in the "Validation" tab for a view / dataset
6. `datahub ingest -c ../../metadata_recipes/dbt.yaml`

## Looking at metadata
- Airflow
  - See pipeline description and lineage
  - tasks -> see run
  - "View in UI"

## TODO:
- Add more metadata like data owners, tags etc https://www.youtube.com/watch?v=aCiOZcWM1J0
- Add link to dashboard
- Use more interesting data and improve on names
- Figure out nice way to delete metadata, like after you drop a table
