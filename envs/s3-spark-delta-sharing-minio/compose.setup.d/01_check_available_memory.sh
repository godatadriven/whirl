#!/usr/bin/env bash

function check_docker_mem() {
    echo "==============================================="
    echo "== Check if there is enough available memory =="
    echo "==============================================="
    MEM_12_POINT_5_GB=$(((1024 * 1024 * 1024 * 25)/2))
    AVAILABLE_MEM=$(docker info -f "{{json .MemTotal}}")

    if [ "${AVAILABLE_MEM}" -lt "${MEM_12_POINT_5_GB}" ]; then
        echo "NOT ENOUGH MEMORY AVAILABLE ($(bc <<< "scale=1; $AVAILABLE_MEM / 1024 / 1024 / 1024")). Need at least 12.5GB"
        exit 12;
    fi
}

check_docker_mem