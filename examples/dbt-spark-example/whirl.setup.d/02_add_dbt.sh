#!/usr/bin/env bash
sudo apt-get install -y libsasl2-dev build-essential
pip install dbt-core==1.4.5 dbt-spark[PyHive] airflow-dbt-python

#airflow-dbt-python depends on the fs_default connection
echo "====================================="
echo "== Configure FS Default connection =="
echo "====================================="
airflow connections add fs_default \
    --conn-type fs \
    --conn-extra "{\"path\": \"/\"}"

sudo chmod -R ugo+rw /opt/airflow/dags/dbt-spark-example/dbt