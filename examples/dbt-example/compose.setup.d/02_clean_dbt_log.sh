#!/usr/bin/env bash

function empty_log_dir() {
    echo "====================================="
    echo "== Cleanup local DBT log mount dir =="
    echo "====================================="
    local SCRIPT_DIR=$( dirname ${BASH_SOURCE[0]} )
    DBT_LOG_DIR="${SCRIPT_DIR}/../dbt/logs"

    if [ "$(ls -A ${DBT_LOG_DIR})" ]; then
        echo "${DBT_LOG_DIR} is not empty. Clearing NOW!!"
        find ${DBT_LOG_DIR} -mindepth 1 -not -name ".gitkeep" -delete
    else
        echo "${DBT_LOG_DIR} is empty. Continue"
    fi
}

empty_log_dir
