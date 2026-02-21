#!/usr/bin/env bash
# Might be empty
AIRFLOW_COMMAND="${1}"
if [[ ${AIRFLOW_COMMAND} == "scheduler" || ${AIRFLOW_COMMAND} == "api-server" || ${AIRFLOW_COMMAND} == "triggerer"  || ${AIRFLOW_COMMAND} == "dag-processor" ]]; then
  echo  "wait a while for the other systems to be started"
  sleep 15
fi

if [[ ${AIRFLOW_COMMAND} == "scheduler" || ${AIRFLOW_COMMAND} == "singlemachine" ]]; then
  echo "========================================="
  echo "== Reset Airflow ========================"
  echo "========================================="
  rm -rf ${AIRFLOW_HOME}/*.pid
  rm -rf ${AIRFLOW_HOME}/*.err
  rm -rf ${AIRFLOW_HOME}/*.log
  rm -rf ${AIRFLOW_HOME}/logs/*
  airflow db reset -y && airflow db migrate
else
  if [[ ${AIRFLOW_COMMAND} == "api-server" || ${AIRFLOW_COMMAND} == "triggerer"  || ${AIRFLOW_COMMAND} == "dag-processor" ]]; then
    echo "wait a bit more to let the scheduler do the database reset."
    sleep 30
  fi
fi

echo "========================================="
echo "== Setup environment specifics =========="
echo "========================================="
for filename in ${WHIRL_SETUP_FOLDER}/env.d/*.sh; do
  echo "Executing environment prepare script: $filename"
  . "$filename"
done

echo "========================================="
echo "== Setup DAG specifics =================="
echo "========================================="
for filename in ${WHIRL_SETUP_FOLDER}/dag.d/*.sh; do
  echo "Executing DAG prepare script: $filename"
  . "$filename"
done

if [[ ${AIRFLOW_COMMAND} == "singlemachine" ]]; then
  nohup /entrypoint scheduler &
  nohup /entrypoint dag-processor &
  nohup /entrypoint api-server -p 5000 &
  /entrypoint triggerer
else
  /entrypoint "${@}"
fi
