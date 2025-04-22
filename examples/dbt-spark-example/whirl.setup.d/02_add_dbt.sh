#!/usr/bin/env bash
sudo apt-get install -y libsasl2-dev build-essential
pip install "dbt-core==1.8.2" dbt-spark[PyHive] "airflow-dbt-python==2.1.0"

#airflow-dbt-python depends on the fs_default connection
echo "====================================="
echo "== Configure FS Default connection =="
echo "====================================="
airflow connections add fs_default \
    --conn-type fs \
    --conn-extra "{\"path\": \"/\"}"

sudo chmod -R ugo+rw /opt/airflow/dags/dbt-spark-example/dbt
