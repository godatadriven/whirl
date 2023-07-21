#!/usr/bin/env bash
sudo apt-get install -y libsasl2-dev build-essential
pip install agate==1.6.1 airflow-dbt dbt-spark[PyHive]

sudo chmod -R ugo+rw /opt/airflow/dags/dbt-spark-example/dbt