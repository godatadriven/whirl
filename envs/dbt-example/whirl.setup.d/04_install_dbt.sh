#!/usr/bin/env bash

sudo apt update && sudo apt install build-essential libsasl2-dev -y
pip install dbt airflow-dbt dbt-spark
