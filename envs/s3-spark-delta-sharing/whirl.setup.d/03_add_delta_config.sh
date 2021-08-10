#!/usr/bin/env bash
echo "=============================================="
echo "== Configure Delta and Delta Sharing config =="
echo "=============================================="
sudo apt-get update && sudo apt-get install -y git

pip install delta-spark==${DELTA_VERSION}
# pip install delta-sharing
# master contains a non-released fix to enable reading from pandas when stats are not available
# thats why we install from git for now.
pip install git+https://github.com/delta-io/delta-sharing.git#egg=delta-sharing\&subdirectory=python
# Install fsspec from PR until this is properly released
pip install git+https://github.com/intake/filesystem_spec.git@refs/pull/718/head

echo '{
  "shareCredentialsVersion": 1,
  "endpoint": "http://delta:8080/delta-sharing/",
  "bearerToken": "authTokenDeltaSharing432"
}' > /opt/airflow/delta.profile
