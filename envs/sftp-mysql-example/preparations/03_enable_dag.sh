#!/usr/bin/env bash

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
