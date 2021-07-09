#!/usr/bin/env bash

function empty_s3_dir() {
    echo "================================"
    echo "== Cleanup local S3 mount dir =="
    echo "================================"
    local SCRIPT_DIR=$( dirname ${BASH_SOURCE[0]} )
    S3_MOUNT_DIR="${SCRIPT_DIR}/../.s3-mount"

    if [ "$(ls -A ${S3_MOUNT_DIR})" ]; then
        echo "${S3_MOUNT_DIR} is not empty. Clearing NOW!!"
        find ${S3_MOUNT_DIR} -mindepth 1 -delete
    else
        echo "${S3_MOUNT_DIR} is empty. Continue"
    fi
}

empty_s3_dir