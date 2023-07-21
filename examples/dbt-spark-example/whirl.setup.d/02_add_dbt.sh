#!/usr/bin/env bash
sudo apt-get install -y libsasl2-dev build-essential
pip install agate==1.6.1 airflow-dbt dbt-spark[PyHive]

sudo chown -R airflow:root /opt/airflow/dags/dbt-spark-example/dbt
sudo chmod -R 644 /opt/airflow/dags/dbt-spark-example/dbt