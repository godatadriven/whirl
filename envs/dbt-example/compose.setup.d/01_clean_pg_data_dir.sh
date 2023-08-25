#!/usr/bin/env bash

function empty_data_dir() {
    echo "================================"
    echo "== Cleanup local PG mount dir =="
    echo "================================"
    local SCRIPT_DIR=$( dirname ${BASH_SOURCE[0]} )
    PG_DATA_DIR="${SCRIPT_DIR}/../.pgdata"

    if [ "$(ls -A ${PG_DATA_DIR})" ]; then
        echo "${PG_DATA_DIR} is not empty. Clearing NOW!!"
        find ${PG_DATA_DIR} -mindepth 1 -delete
    else
        echo "${PG_DATA_DIR} is empty. Continue"
    fi
}

empty_data_dir