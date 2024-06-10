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

cd /tmp/rawdata
awslocal s3 cp --recursive --exclude "*" --include "*.csv" . s3://hub-raw-source-bucket/

awslocal glue start-crawler --name HubRawSourceCrawler
