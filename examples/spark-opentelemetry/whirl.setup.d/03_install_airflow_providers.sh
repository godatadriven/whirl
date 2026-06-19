#!/usr/bin/env bash
set -e

echo "========================================"
echo "== Install required airflow providers =="
echo "========================================"

uv pip install --no-cache-dir "apache-airflow[otel]==${AIRFLOW_VERSION}"
