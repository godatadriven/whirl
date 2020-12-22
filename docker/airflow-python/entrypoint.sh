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
  echo "y" | airflow resetdb
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
  if [ -x "$filename" ]; then
    "$filename"
  else
    . "$filename"
  fi
done

echo "========================================="
echo "== Setup DAG specifics =================="
echo "========================================="
for filename in ${WHIRL_SETUP_FOLDER}/dag.d/*.sh; do
  echo "Executing DAG prepare script: $filename"
  if [ -x "$filename" ]; then
    "$filename"
  else
    . "$filename"
  fi
done

if [[ ${AIRFLOW_COMMAND} == "webserver" || ${AIRFLOW_COMMAND} == "singlemachine" ]]; then

  if [ "${UNPAUSE_DAG}" = true ]; then
    echo "================================="
    echo "== Enabling all available DAGs =="
    echo "================================="
    # Airflow "helpfully" prints a bunch of logging before the DAG names when you run the list-dags command. The bit of info
    # we're looking for is preceded by "-------\nDAGS\n--------\n". The awk script suppresses all output until it has seen
    # two dashed lines, after which it prints every line.
    for d in $(airflow list_dags 2>/dev/null | awk 'START{ line = 0 }/----/{ line += 1 }!/----/{ if (line >= 2) print $0 }')
    do
      echo "Enabling DAG ${d}"
      airflow unpause "${d}" || true
    done
  fi
fi

if [[ ${AIRFLOW_COMMAND} == "singlemachine" ]]; then
  nohup /entrypoint scheduler -D &
  # echo  "wait a while for the scheduler to be started"
  # sleep 15
  /entrypoint webserver -p 5000
else
  /entrypoint "${@}"
fi