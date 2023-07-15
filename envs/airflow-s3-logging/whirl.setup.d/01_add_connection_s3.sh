#!/usr/bin/env bash

echo "============================="
echo "== Configure S3 Connection =="
echo "============================="
airflow connections add local_s3 \
          --conn-type s3 \
          --conn-extra "{\"endpoint_url\": \"http://${AWS_SERVER}:${AWS_PORT}\",
                         \"aws_secret_access_key\": \"${AWS_SECRET_ACCESS_KEY}\",
                         \"aws_access_key_id\": \"${AWS_ACCESS_KEY_ID}\",
                         \"host\": \"http://${AWS_SERVER}:${AWS_PORT}\"
                        }"

pip install awscli awscli-plugin-endpoint

echo -e "$AWS_ACCESS_KEY_ID\n$AWS_SECRET_ACCESS_KEY\n\n" | aws configure
aws configure set plugins.endpoint awscli_plugin_endpoint
aws configure set default.s3.endpoint_url http://${AWS_SERVER}:${AWS_PORT}
aws configure set default.s3api.endpoint_url http://${AWS_SERVER}:${AWS_PORT}

echo "================================"
echo "== Create S3 Bucket ==========="
echo "================================"
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://${AWS_SERVER}:${AWS_PORT})" != "200" ]]; do
  echo "Waiting for ${AWS_SERVER} to come up..."
  sleep 2;
done

echo "creating bucket"
aws s3api create-bucket --bucket ${S3_LOG_BUCKET}
