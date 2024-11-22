#!/usr/bin/env bash

echo "================================="
echo "== Install required spark jars =="
echo "================================="

export SPARK_HOME=$(python ~/.local/bin/find_spark_home.py)
cp /etc/airflow/whirl.setup.d/dag.d/spot-complete_2.12-0.0.0+21-da7895dc.jar ${SPARK_HOME}/jars/spot-complete.jar
