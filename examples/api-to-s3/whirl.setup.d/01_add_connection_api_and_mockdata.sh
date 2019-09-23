#!/usr/bin/env bash

echo "=============================="
echo "== Configure API Connection =="
echo "=============================="

airflow connections -a \
          --conn_id local_api \
          --conn_type HTTP \
          --conn_host "http://mockserver:1080/testapi" \
          --conn_login apitest \
          --conn_password testapi


# Creating a expectation for our mockserver to respond to a specific api rest call with a fixed set of JSON data
# Fro docs on creating expectations see: http://www.mock-server.com/mock_server/creating_expectations.html
curl -v -X PUT "http://mockserver:1080/mockserver/expectation" -d '{
  "httpRequest": {
    "path": "/testapi",
    "headers": {
        "Authorization": ["Basic .*"]
    }
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
      "json": "[{\"country\": \"Oman\", \"city\": \"Timaru\", \"lat\": 10.3398, \"lon\": -172.55031, \"dt\": 1578207382, \"type\": \"Acura\", \"color\": \"violet\"}, {\"country\": \"Denmark\", \"city\": \"La Cruz\", \"lat\": -44.10906, \"lon\": 2.4756, \"dt\": 1546852920, \"type\": \"Audi\", \"color\": \"orange\"}, {\"country\": \"Burundi\", \"city\": \"Pessac\", \"lat\": -68.89785, \"lon\": 4.89982, \"dt\": 1543912959, \"type\": \"BMW\", \"color\": \"red\"}, {\"country\": \"Aruba\", \"city\": \"Jemeppe-sur-Meuse\", \"lat\": -43.89882, \"lon\": -63.38649, \"dt\": 1520321854, \"type\": \"Peugeot\", \"color\": \"green\"}, {\"country\": \"Gambia\", \"city\": \"Pak Pattan\", \"lat\": -37.21457, \"lon\": -94.19453, \"dt\": 1570869730, \"type\": \"Daimler\", \"color\": \"yellow\"}]"
    }
  }
}'

pip install pandas pyarrow

mkdir -p /tmp/whirl-local-api-to-s3-example/