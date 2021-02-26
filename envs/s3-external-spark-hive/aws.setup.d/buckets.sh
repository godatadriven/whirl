#!/bin/bash
set -x
awslocal s3 mb s3://$HIVE_DW_BUCKET

set +x
