#!/usr/bin/env bash

echo "========================================"
echo "== Install required airflow providers =="
echo "========================================"

pip install apache-airflow-providers-apache-spark
pip install airflow-provider-great-expectations==0.0.8 #fixed version to be able to use v2 api