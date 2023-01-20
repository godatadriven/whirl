#!/bin/bash
set -e # exit immediately if a command exits with a non-zero status.

POSTGRES="psql --username $POSTGRES_USER"

# create database for superset
echo "Creating database: $MB_DB_DBNAME"
$POSTGRES <<EOSQL
CREATE DATABASE $MB_DB_DBNAME OWNER $MB_DB_USER;
EOSQL
