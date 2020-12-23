#!/usr/bin/env bash

echo "==================================="
echo "== Configure Postgres Connection =="
echo "==================================="
airflow connections add \
          local_pg \
          --conn-type postgres \
          --conn-host ${POSTGRES_HOST} \
          --conn-port ${POSTGRES_PORT} \
          --conn-login ${POSTGRES_USER} \
          --conn-password ${POSTGRES_PASSWORD} \
          --conn-schema ${POSTGRES_DB} \
          --conn-extra "{\"conn-prefix\": \"jdbc:postgresql://\"}"

