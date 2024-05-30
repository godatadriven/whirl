#!/usr/bin/env bash

echo "=================="
echo "== Configure S3 =="
echo "=================="
airflow connections add \
          localstack_conn \
          --conn-type aws \
          --conn-extra "{\"endpoint_url\": \"${AWS_ENDPOINT_URL}\",
                         \"aws_secret_access_key\": \"${AWS_SECRET_ACCESS_KEY}\",
                         \"aws_access_key_id\": \"${AWS_ACCESS_KEY_ID}\",
                         \"region_name\": \"${AWS_REGION}\",
                        }"

pip install awscli awscli-plugin-endpoint

echo -e "$AWS_ACCESS_KEY_ID\n$AWS_SECRET_ACCESS_KEY\n\n" | aws configure
aws configure set plugins.endpoint awscli_plugin_endpoint
aws configure set default.s3.endpoint_url ${AWS_ENDPOINT_URL}
aws configure set default.s3api.endpoint_url ${AWS_ENDPOINT_URL}
