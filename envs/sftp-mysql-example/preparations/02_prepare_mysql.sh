#!/usr/bin/env bash

echo "========================================"
echo "== Configure MySQL ====================="
echo "========================================"

airflow connections -a --conn_id mysql_connection \
                       --conn_type mysql \
                       --conn_schema my_database \
                       --conn_host mysql \
                       --conn_login $MYSQL_USER \
                       --conn_port 3306 \
                       --conn_password $MYSQL_PASSWORD
