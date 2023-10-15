#!/usr/bin/env bash
sudo apt-get install -y libsasl2-dev build-essential
pip install dbt-core==1.4.5 airflow-dbt-python

#airflow-dbt-python depends on the fs_default connection
echo "====================================="
echo "== Configure FS Default connection =="
echo "====================================="
airflow connections add fs_default \
    --conn-type fs \
    --conn-extra "{\"path\": \"/\"}"
