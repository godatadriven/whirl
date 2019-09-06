#!/usr/bin/env bash
echo "========================================="
echo "== Initialize Airflow ==================="
echo "========================================="
airflow upgradedb
echo "========================================="
echo "== Reset Airflow ========================"
echo "========================================="
rm -rf ${AIRFLOW_HOME}/*.pid
rm -rf ${AIRFLOW_HOME}/*.err
rm -rf ${AIRFLOW_HOME}/*.log
rm -rf ${AIRFLOW_HOME}/logs/*
echo "y" | airflow resetdb
echo "Removing airflows default connections"
python /delete_all_airflow_connections.py

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

echo "Starting Airflow scheduler..."
nohup airflow scheduler -D &

echo  "wait a while for the scheduler to be started"
sleep 15

echo "If needed, unpause dags..."
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
  end
fi

echo "Starting Airflow webserver..."
airflow webserver -p 5000
