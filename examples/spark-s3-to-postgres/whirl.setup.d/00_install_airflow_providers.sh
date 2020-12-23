#!/usr/bin/env bash

echo "========================================"
echo "== Install required airflow providers =="
echo "========================================"

pip install apache-airflow-providers-apache-spark
aws s3api put-object --bucket ${DEMO_BUCKET} --key input/data/demo/spark/$(date "+%Y%m%d")/data.json --body /mock-data/input.json
