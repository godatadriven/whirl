#!/usr/bin/env bash

echo "========================================"
echo "== Install required airflow providers =="
echo "========================================"

pip install apache-airflow-providers-mysql "paramiko==3.5.1" apache-airflow-providers-sftp
