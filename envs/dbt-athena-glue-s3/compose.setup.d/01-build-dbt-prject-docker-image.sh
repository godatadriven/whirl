#!/usr/bin/env bash

REG_DATA_DIR=${ENVIRONMENT_FOLDER}/.docker-registry-persistence

function empty_registry_data_dir() {
    echo "============================"
    echo "== Cleanup local data dir =="
    echo "============================"
    if [ "$(ls -A ${REG_DATA_DIR} | grep -v 'gitkeep')" ]; then
        echo "${REG_DATA_DIR} is not empty. Clearing NOW!!"
        find ${REG_DATA_DIR}  -not -name '.gitkeep' -mindepth 1 -delete
    else
        echo "${REG_DATA_DIR} is empty. Continue"
    fi
}

function publish_dbt_image() {
    echo "==============================================="
    echo "== Start local docker registry               =="
    echo "==============================================="
    docker run -d \
        -p 5000:5000 \
        -v ${REG_DATA_DIR}:/var/lib/registry \
        --name registry \
        --rm \
        registry:2
    echo "================================"
    echo "== Build DBT project image    =="
    echo "================================"
    docker build -t "dbt-project:local" -f "${ENVIRONMENT_FOLDER}/compose.setup.d/Dockerfile.dbt" ${DAG_FOLDER}
    echo "================================"
    echo "== Tag DBT project image      =="
    echo "================================"
    docker tag "dbt-project:local" localhost:5000/dbt-project:latest
    echo "================================"
    echo "== Push DBT project image     =="
    echo "================================"
    docker push localhost:5000/dbt-project:latest
    echo "================================"
    echo "== Stop local docker registry =="
    echo "================================"
    docker stop registry
}

empty_registry_data_dir
publish_dbt_image
