#!/usr/bin/env bash

echo "============================="
echo "========== Datahub =========="
echo "============================="

pip install acryl-datahub-airflow-plugin

airflow connections add  --conn-type 'datahub_rest' 'datahub_rest_default' --conn-host 'http://datahub-gms:8080' # --conn-password '<optional datahub auth token>'
