#!/usr/bin/env bash
set -e

echo "=================="
echo "== Configure S3 =="
echo "=================="

pip install --disable-pip-version-check --progress-bar=raw --no-cache-dir uv
uv pip install --no-cache-dir awscli awscli-plugin-endpoint

echo -e "$AWS_ACCESS_KEY_ID\n$AWS_SECRET_ACCESS_KEY\n\n" | aws configure
aws configure set plugins.endpoint awscli_plugin_endpoint
aws configure set default.s3.endpoint_url "http://${AWS_SERVER}:${AWS_PORT}"
aws configure set default.s3api.endpoint_url "http://${AWS_SERVER}:${AWS_PORT}"

echo "======================"
echo "== Create S3 Bucket =="
echo "======================"

echo "Waiting for ${AWS_SERVER} to come up..."
curl --fail \
     --silent \
     --retry 30 \
     --retry-delay 5 \
     --output /dev/null \
     --connect-timeout 5 \
     --retry-connrefused \
     --url "http://${AWS_SERVER}:${AWS_PORT}"

echo "Creating bucket"
aws s3api create-bucket --bucket "${DEMO_BUCKET}"
