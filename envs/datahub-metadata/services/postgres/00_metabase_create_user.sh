#!/bin/bash
set -e # exit if a command exits with a not-zero exit code

POSTGRES="psql -U $POSTGRES_USER"

# create a shared role to read & write general datasets into postgres
echo "Creating database role: $MB_DB_USER"
$POSTGRES <<-EOSQL
CREATE USER $MB_DB_USER WITH
    LOGIN
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOINHERIT
    NOREPLICATION
    PASSWORD '$MB_DB_PASS';
EOSQL
