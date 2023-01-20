# DataHub POC
This example uses the [datahub-metadata environment](../envs/datahub-metadata/) to spin up:
- Airflow: this part is based on other environments in this repository.
  - Airflow itself
    - airflow
  - Mock Server
    - mockserver
  - S3 Server
    - s3server
  - Postgres Database
    - postgresdb
- DataHub: this part is based on https://github.com/datahub-project/datahub/blob/master/docker/quickstart/docker-compose-without-neo4j-m1.quickstart.yml
  - Kafka
    - broker
    - schema-registry
    - zookeeper
    - kafka-setup
  - DataHub
    - datahub-actions
    - datahub-gms
  - Elastic Search
    - elasticsearch
    - elasticsearch-setup
  - MySQL
    - mysql
    - mysql-setup


## Creating your python env
Use conda to create your python environment using `conda env create --file environment.yml`


## Adding metadata

### Postgres

More information on postgres [can be found here](https://datahubproject.io/docs/generated/ingestion/sources/postgres)

Set `export POSTGRES_PASSWORD=p@ssw0rd`
[Edit this file](./metadata_recipes/postgres.yaml)
`datahub ingest -c metadata_recipes/postgres.yaml`

### Airflow

- Follow steps [here](https://datahubproject.io/docs/lineage/airflow), to set up airflow with DataHub, this will allow Airflow to sync metadata with DataHub.
- Add a description to your DAG object
- Run airflow DAG

### dbt

There's a lot of information on adding dbt metadata [here](https://datahubproject.io/docs/generated/ingestion/sources/dbt)

#### Writing the dbt recipe
We've created a recipe [here](./metadata_recipes/dbt.yaml), based on information:
- [Starter Recipe](https://datahubproject.io/docs/generated/ingestion/sources/dbt#starter-recipe)
- [Metadata](https://datahubproject.io/docs/generated/ingestion/sources/dbt#dbt-meta-automated-mappings)
  - `meta_mapping`: `meta` [config for dbt models]
  - `column_meta_mapping`: `meta` config for columns in dbt models
  - `query_tag_mapping`: `tag`

#### Ingesting metadata

1. Move cli to [dbt directory](./dbt/datahub_poc) `cd dbt/datahub_poc`
2. `export DBT_PROFILES_DIR=$(pwd)`
3. `dbt run`
4. `dbt docs generate`
5. `dbt test`, run this last, so the test results are shown in the "Validation" tab for a view / dataset
6. `datahub ingest -c ../../metadata_recipes/dbt.yaml`


### Metabase

Used the information [here](https://datahubproject.io/docs/generated/ingestion/sources/metabase/)

1. Create a chart and a dashboard using [metabase](http://localhost:3001)
2. Fill in your username and password [here](./metadata_recipes/metabase.yaml)
3. Ingest metadata: `datahub ingest -c ../../metadata_recipes/metabase.yaml`


## Looking at metadata
- Airflow
  - See pipeline description and lineage
  - tasks -> see run
  - "View in UI"

## TODO:
- We could definitely clean up the docker-compose file
  - There are a lot of values declared in multiple places, e.g. `MYSQL_PASSWORD`
- Figure out nice way to delete metadata, like after you drop a table
- Use more interesting data and improve on names
