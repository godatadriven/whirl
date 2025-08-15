#!/usr/bin/env bash

echo "============================="
echo "== Configure API Responses =="
echo "============================="

# Creating a expectation for our mockserver to respond to a specific api rest call with a pendig status for the first 30 invocations
# For docs on creating expectations see: http://www.mock-server.com/mock_server/creating_expectations.html
curl -v -X PUT "http://mockserver:1080/mockserver/expectation" -d '{
  "id": "pending_expectation",
  "httpRequest": {
    "path": "/testapi"
  },
  "httpResponse": {
    "statusCode": 200,
    "headers": {
      "content-type": [
        "application/json"
      ]
    },
    "body": {
      "type": "JSON",
      "json": "{\"status\": \"Pending\"}"
    }
  },
  "times": {
    "remainingTimes": 30,
    "unlimited": false
  },
  "timeToLive": {
    "unlimited": true
  },
  "priority": 10
}'

curl -v -X PUT "http://mockserver:1080/mockserver/expectation" -d '{
  "id": "started_expectation",
  "httpRequest": {
    "path": "/testapi"
  },
  "httpResponse": {
    "statusCode": 200,
    "headers": {
      "content-type": [
        "application/json"
      ]
    },
    "body": {
      "type": "JSON",
      "json": "{\"status\": \"Started\"}"
    }
  },
  "priority": 0
}'

# From Airflow 3.0.2, the `dags` folder (a.k.a. the DagBundle) is no longer automatically included on the PYTHONPATH
# This means that in order to use our custom Python modules, we need to install the custom directory. We also
# added a small `setup.py` to make this work, as well as volume mounts in the compose override.
sudo chmod -R ugo+rw /opt/airflow/custom/build

pip install aiohttp /opt/airflow/custom/
