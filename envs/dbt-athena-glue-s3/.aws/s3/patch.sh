#!/bin/bash

sed -i -e 's#dlcdn.apache.org#archive.apache.org/dist#g' /opt/code/localstack/.venv/lib/python3.11/site-packages/localstack_ext/packages/hive.py
