#!/usr/bin/env bash
echo "=============================================="
echo "== Configure Delta and Delta Sharing config =="
echo "=============================================="
sudo apt-get update && sudo apt-get install -y git

pip install delta-spark==${DELTA_VERSION}
pip install delta-sharing==${DELTA_SHARING_VERSION}
# Install fsspec from PR until this is properly released
pip install git+https://github.com/intake/filesystem_spec.git@refs/pull/718/head

echo '{
  "shareCredentialsVersion":1,
  "bearerToken":"e8bfdf7f-4d39-46c7-8d04-21becdb2b201",
  "endpoint":"http://delta:8000/api/v1"
}' > /opt/airflow/delta.profile
