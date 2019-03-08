#!/usr/bin/env bash

echo "=========================="
echo "== Setup Mockdata in S3 =="
echo "=========================="

aws s3api put-object --bucket ${DEMO_BUCKET} --key input/data/demo/spark/$(date "+%Y%m%d")/data.json --body /mock-data/input.json
