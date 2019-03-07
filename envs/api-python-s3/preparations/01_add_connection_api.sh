#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID=bar
export AWS_SECRET_ACCESS_KEY=foo

echo "============================="
echo "== Configure S3 Connection =="
echo "============================="
airflow connections -a \
          --conn_id local_s3 \
          --conn_type s3 \
          --conn_extra "{\"endpoint_url\": \"http://s3server:4563\",
                         \"aws_secret_access_key\": \"${AWS_SECRET_ACCESS_KEY}\",
                         \"aws_access_key_id\": \"${AWS_ACCESS_KEY_ID}\",
                         \"host\": \"http://s3server:4563\"
                        }"

pip install awscli awscli-plugin-endpoint

echo -e "$AWS_ACCESS_KEY_ID\n$AWS_SECRET_ACCESS_KEY\n\n" | aws configure
aws configure set plugins.endpoint awscli_plugin_endpoint
aws configure set default.s3.endpoint_url http://s3server:4563
aws configure set default.s3api.endpoint_url http://s3server:4563

echo "================================"
echo "== Create S3 Bucket ==========="
echo "================================"
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://s3server:8080)" != "200" ]]; do
  echo "Waiting for s3server to come up..."
  sleep 2;
done

echo "creating bucket"
S3_SERVER_IP=$(dig +short s3server)
aws s3api create-bucket --bucket "demo-s3-output"
echo -e "${S3_SERVER_IP}\tdemo-s3-output.s3server" >> /etc/hosts
