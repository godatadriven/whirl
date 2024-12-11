#!/usr/bin/env bash
pip install \
    "dbt-postgres==${DBT_VERSION}" \
    "apache-airflow[spark,openlineage]==${AIRFLOW_VERSION}"

sudo chmod -R ugo+rw /opt/airflow/dags/dbt-example/dbt

echo "-*=*==*====*==[dbt installation]==*===*==*=*-"
dbt --version
echo "-*=*==*====*======================*===*==*=*-"
