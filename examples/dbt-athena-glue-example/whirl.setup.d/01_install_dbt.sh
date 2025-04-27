#!/usr/bin/env bash

pip install astronomer-cosmos[dbt-athena]==1.9.2

sudo chmod -R ugo+rw /opt/airflow/dags/dbt-athena-glue-example/dbt

cd /opt/airflow/dags/dbt-athena-glue-example/dbt
dbt deps
dbt parse
