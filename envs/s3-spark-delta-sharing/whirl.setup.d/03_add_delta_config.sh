#!/usr/bin/env bash
echo "=============================================="
echo "== Configure Delta and Delta Sharing config =="
echo "=============================================="
sudo apt-get update && sudo apt-get install -y git

pip install delta-spark==${DELTA_VERSION}
# pip install delta-sharing
pip install git+https://github.com/delta-io/delta-sharing.git#egg=delta-sharing\&subdirectory=python
pip install git+https://github.com/intake/filesystem_spec.git@refs/pull/718/head

echo '{
  "shareCredentialsVersion": 1,
  "endpoint": "http://delta:8080/delta-sharing/",
  "bearerToken": "authTokenDeltaSharing432"
}' > /opt/airflow/delta.profile
