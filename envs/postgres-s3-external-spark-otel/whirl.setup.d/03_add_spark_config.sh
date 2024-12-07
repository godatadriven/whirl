#!/usr/bin/env bash
set -e
echo "============================"
echo "======== Add java =========="
echo "============================"

sudo apt-get update && sudo apt-get install -y openjdk-17-jre

echo "============================"
echo "== Configure Spark config =="
echo "============================"
airflow connections add spark_default \
    --conn-type spark \
    --conn-host "spark://sparkmaster:7077" \
    --conn-extra "{\"queue\": \"root.default\", \"deploy-mode\": \"client\"}"

SDK_AWS_VERSION=1.12.262
HADOOP_AWS_VERSION=3.3.4

POSTGRES_JDBC_CHECKSUM=7ffa46f8c619377cdebcd17721b6b21ecf6659850179f96fec3d1035cf5a0cdc
SDK_AWS_CHECKSUM=873fe7cf495126619997bec21c44de5d992544aea7e632fdc77adb1a0915bae5
HADOOP_AWS_CHECKSUM=53f9ae03c681a30a50aa17524bd9790ab596b28481858e54efd989a826ed3a4a

uv pip install --no-cache-dir "pyspark==${SPARK_VERSION}" apache-airflow-providers-apache-spark

export SPARK_HOME=$(python ~/.local/bin/find_spark_home.py)
echo "-------------------------------"
echo "SPARK_HOME set to ${SPARK_HOME}"
echo "-------------------------------"

# The /mnt/spark_downloads is a Docker volume. By staging the file there we avoid downloads on repeated runs.
sudo chown $UID /mnt/spark_downloads
add_spark_jar() {
    local DOWNLOAD_URL="$1"
    local CHECKSUM="$2"
    local FILENAME="${3:-$(basename $1)}"
    local STAGING_DIR="${4:-/mnt/spark_downloads}"
    local DEST_DIR="${5:-${SPARK_HOME}/jars}"
    local DEST_FILE="${DEST_DIR}/${FILENAME}"
    local STAGING_FILE="${STAGING_DIR}/${FILENAME}"
    if [ ! -f "${STAGING_FILE}" ]; then
        echo "Downloading ${FILENAME}"
        curl --progress-bar --connect-timeout 10 --fail \
             --output "${STAGING_FILE}" \
             --url "${DOWNLOAD_URL}"
    else
        echo "Using cached ${FILENAME}"
    fi
    echo "Verifying checksum of ${FILENAME}"
    echo "${CHECKSUM} ${STAGING_FILE}" | sha256sum -c -
    cp -f "${STAGING_FILE}" "${DEST_FILE}"
    echo "Successfully copied ${FILENAME} to ${DEST_DIR}"
}

add_spark_jar "https://jdbc.postgresql.org/download/postgresql-42.2.5.jar" \
              "$POSTGRES_JDBC_CHECKSUM"
add_spark_jar "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${SDK_AWS_VERSION}/aws-java-sdk-bundle-${SDK_AWS_VERSION}.jar" \
              "$SDK_AWS_CHECKSUM"
add_spark_jar "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar" \
              "$HADOOP_AWS_CHECKSUM"
