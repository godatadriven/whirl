#!/usr/bin/env bash
pip install dbt-postgres

# make sure dbt can access the dbt project folder
chmod -R 777 /opt/airflow/dags