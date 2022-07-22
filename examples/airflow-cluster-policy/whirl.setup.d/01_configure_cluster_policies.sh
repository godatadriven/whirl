#!/usr/bin/env bash

echo "========================"
echo "== Configure policies =="
echo "========================"

mkdir -p ${AIRFLOW_HOME}/config

SCRIPT_DIR=$(dirname "${BASH_SOURCE}")

echo "Configure dag policies from ${SCRIPT_DIR}/policies/dag_policy.py"
cat ${SCRIPT_DIR}/policies/dag_policy.py > ${AIRFLOW_HOME}/config/airflow_local_settings.py