#!/usr/bin/env bash

echo "==================================="
echo "== Configure OpenMetadata        =="
echo "==================================="
pip install "openmetadata-ingestion[airflow-container]" "openmetadata-managed-apis"