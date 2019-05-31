#!/usr/bin/env bash

echo "==================================="
echo "== Configure Postgres Connection =="
echo "==================================="
airflow connections -a \
          --conn_id local_pg \
          --conn_type postgres \
          --conn_host ${POSTGRES_HOST} \
          --conn_port ${POSTGRES_PORT} \
          --conn_login ${POSTGRES_USER} \
          --conn_password ${POSTGRES_PASSWORD} \
          --conn_schema ${POSTGRES_DB} \
          --conn_extra "{\"conn_prefix\": \"jdbc:postgresql://\"}"

