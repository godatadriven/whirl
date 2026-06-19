#!/usr/bin/env bash
set -e

echo "====================="
echo "== Configure MySQL =="
echo "====================="

airflow connections add mysql_connection \
                       --conn-type mysql \
                       --conn-schema my_database \
                       --conn-host mysql \
                       --conn-login $MYSQL_USER \
                       --conn-port 3306 \
                       --conn-password $MYSQL_PASSWORD
