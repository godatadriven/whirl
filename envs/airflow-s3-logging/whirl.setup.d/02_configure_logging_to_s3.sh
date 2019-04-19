#!/usr/bin/env bash

echo "=========================="
echo "== Configure S3 logging =="
echo "=========================="
export AIRFLOW__CORE__EXPOSE_CONFIG=True
export AIRFLOW__CORE__REMOTE_LOGGING=True
export AIRFLOW__CORE__REMOTE_BASE_LOG_FOLDER=s3://${S3_LOG_BUCKET}/airflow-spark-docker
export AIRFLOW__CORE__REMOTE_LOG_CONN_ID=local_s3
export AIRFLOW__CORE__ENCRYPT_S3_LOGS=False
