#!/usr/bin/env bash

function empty_local_data_share_dir() {
    echo "=================================="
    echo "== Cleanup local data mount dir =="
    echo "=================================="
    local SCRIPT_DIR=$( dirname ${BASH_SOURCE[0]} )
    DATA_MOUNT_DIR="${SCRIPT_DIR}/../.local-data-share"

    if [ "$(ls -A ${DATA_MOUNT_DIR})" ]; then
        echo "${DATA_MOUNT_DIR} is not empty. Clearing NOW!!"
        find ${DATA_MOUNT_DIR} -mindepth 1 -not -name ".gitkeep" -delete
    else
        echo "${DATA_MOUNT_DIR} is empty. Continue"
    fi
}

empty_local_data_share_dir