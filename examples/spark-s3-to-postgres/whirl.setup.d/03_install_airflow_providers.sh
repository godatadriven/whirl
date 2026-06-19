#!/usr/bin/env bash
set -e

echo "========================================"
echo "== Install required airflow providers =="
echo "========================================"

pip install apache-airflow-providers-apache-spark
