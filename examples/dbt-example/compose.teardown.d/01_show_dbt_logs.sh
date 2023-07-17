#!/usr/bin/env bash

function show_logs() {
    echo "======================="
    echo "== Show dbt run logs =="
    echo "======================="
    local SCRIPT_DIR=$( dirname ${BASH_SOURCE[0]} )
    DBT_LOG_DIR="${SCRIPT_DIR}/../dbt/logs"

    if [ "$(ls -A ${DBT_LOG_DIR})" ]; then
        echo "${DBT_LOG_DIR} is not empty. Showing log!!"
        cat ${DBT_LOG_DIR}/dbt.log
    fi
}

show_logs