#!/usr/bin/env bash

function publish_airlfow_worker_image() {
    echo "==============================================="
    echo "== Start local docker registry               =="
    echo "==============================================="
    docker run -d \
        -p 5000:5000 \
        -v ${ENVIRONMENT_FOLDER}/docker-registry-persistence:/var/lib/registry \
        --name registry \
        --rm \
        registry:2
    echo "==============================================="
    echo "== Build Airflow worker image with pandas    =="
    echo "==============================================="
    docker build --build-arg PYTHON_VERSION="${PYTHON_VERSION}" --build-arg AIRFLOW_VERSION="${AIRFLOW_VERSION}" --build-arg DAG_SUBDIR="${PROJECTNAME}" -t "airflow-worker:py-${PYTHON_VERSION}-local" -f "${ENVIRONMENT_FOLDER}/compose.setup.d/Dockerfile.worker" ${DAG_FOLDER}
    echo "==============================================="
    echo "== Tag Airflow worker image                  =="
    echo "==============================================="
    docker tag "airflow-worker:py-${PYTHON_VERSION}-local" localhost:5000/airflow-worker:latest
    echo "==============================================="
    echo "== Push Airflow worker image                 =="
    echo "==============================================="
    docker push localhost:5000/airflow-worker:latest
    echo "==============================================="
    echo "== Stop local docker registry                =="
    echo "==============================================="
    docker stop registry
}

publish_airlfow_worker_image
