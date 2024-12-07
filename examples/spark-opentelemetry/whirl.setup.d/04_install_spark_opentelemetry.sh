#!/usr/bin/env bash

echo "================================="
echo "== Install required spark jars =="
echo "================================="

SPARK_HOME=$(python ~/.local/bin/find_spark_home.py)
export SPARK_HOME
cp /etc/airflow/whirl.setup.d/dag.d/spot-complete.jar "${SPARK_HOME}/jars/spot-complete.jar"
