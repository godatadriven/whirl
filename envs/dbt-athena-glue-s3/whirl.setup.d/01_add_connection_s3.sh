#!/usr/bin/env bash

echo "=================="
echo "== Configure S3 =="
echo "=================="

pip install awscli awscli-plugin-endpoint

echo -e "$AWS_ACCESS_KEY_ID\n$AWS_SECRET_ACCESS_KEY\n\n" | aws configure
aws configure set plugins.endpoint awscli_plugin_endpoint
aws configure set default.s3.endpoint_url ${AWS_ENDPOINT_URL}
aws configure set default.s3api.endpoint_url ${AWS_ENDPOINT_URL}
