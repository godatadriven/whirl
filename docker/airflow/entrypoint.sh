#!/usr/bin/env bash
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

for filename in ${AIRFLOW_PREP_FOLDER}/*.sh; do
  echo "Executing prepare script: $filename"
  if [ -x "$filename" ]; then
    "$filename"
  else
    . "$filename"
  fi
done

echo "Starting Airflow scheduler..."
airflow scheduler -D && sleep 10

airflow webserver -p 5000
