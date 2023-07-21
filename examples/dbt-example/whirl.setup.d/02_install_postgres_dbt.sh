#!/usr/bin/env bash
pip install dbt-postgres

sudo chown -R airflow:root /opt/airflow/dags/dbt-example/dbt
sudo chmod -R 755 /opt/airflow/dags/dbt-example/dbt