#!/usr/bin/env bash
pip install dbt-postgres

sudo chown airflow:root /opt/airflow/dags/dbt-example/dbt/logs