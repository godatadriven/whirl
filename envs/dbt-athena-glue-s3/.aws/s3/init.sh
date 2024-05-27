#!/bin/bash

apt-get install -y gnupg wget lsb-release

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

chmod 644 /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
tee /etc/apt/sources.list.d/hashicorp.list

apt update && apt-get install -y terraform

pip install terraform-local

awslocal s3 mb s3://dbt-staging

cd /opt/code/terraform
tflocal init -reconfigure
tflocal plan
tflocal apply -auto-approve

echo "Name,Service" > data.csv
echo "LocalStack,Athena" >> data.csv

awslocal s3 cp data.csv s3://hub-raw-source-bucket/data/
awslocal s3 cp data/yellow_tripdata_2024-01.parquet.snappy s3://hub-raw-source-bucket/yellow/
awslocal s3 cp data/yellow_tripdata_2024-02.parquet.snappy s3://hub-raw-source-bucket/yellow/

awslocal glue start-crawler --name HubRawSourceCrawler
