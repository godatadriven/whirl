#!/usr/bin/env bash
set -e
pip install \
    "dbt-postgres==${DBT_POSTGRES_VERSION}" \
    apache-airflow-providers-apache-spark \
    apache-airflow-providers-openlineage

sudo chmod -R ugo+rw /opt/airflow/dags/dbt-example/dbt

echo "-*=*==*====*==[dbt installation]==*===*==*=*-"
dbt --version
echo "-*=*==*====*======================*===*==*=*-"
