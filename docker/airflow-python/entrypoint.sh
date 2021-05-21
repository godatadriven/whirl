#!/usr/bin/env bash
# Might be empty
AIRFLOW_COMMAND="${1}"
if [[ ${AIRFLOW_COMMAND} == "scheduler" || ${AIRFLOW_COMMAND} == "webserver" ]]; then
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
  echo "y" | airflow db reset
  airflow users create --username admin --password admin --firstname Anonymous --lastname Admin --role Admin --email admin@example.org
else
  if [[ ${AIRFLOW_COMMAND} == "webserver" ]]; then
    echo "wait a bit more to let the scheduler do the database reset."
    sleep 15
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
  nohup /entrypoint scheduler -D &
  # echo  "wait a while for the scheduler to be started"
  # sleep 15
  /entrypoint webserver -p 5000
else
  /entrypoint "${@}"
fi