#!/usr/bin/env bash

echo "=========================="
echo "== Setup Mockdata in S3 =="
echo "=========================="
sudo apt-get update && sudo apt-get install -y unzip

aws s3api create-bucket --bucket ${DBT_BUCKET}
aws s3api put-object --bucket ${DBT_BUCKET} --key input/data/dbt/$(date "+%Y%m%d")/flights_data.zip --body /mock-data/flights_data.zip
