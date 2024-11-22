#!/usr/bin/env bash
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

pip install pyspark==${SPARK_VERSION}
pip install apache-airflow-providers-apache-spark

export SPARK_HOME=$(python ~/.local/bin/find_spark_home.py)
echo "-------------------------------"
echo "SPARK_HOME set to ${SPARK_HOME}"
echo "-------------------------------"

curl -o ${SPARK_HOME}/jars/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar && \
  echo "$POSTGRES_JDBC_CHECKSUM ${SPARK_HOME}/jars/postgresql-42.2.5.jar" | sha256sum -c -

curl -o ${SPARK_HOME}/jars/aws-java-sdk-bundle-${SDK_AWS_VERSION}.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${SDK_AWS_VERSION}/aws-java-sdk-bundle-${SDK_AWS_VERSION}.jar && \
  echo "$SDK_AWS_CHECKSUM ${SPARK_HOME}/jars/aws-java-sdk-bundle-${SDK_AWS_VERSION}.jar" | sha256sum -c -

curl -o ${SPARK_HOME}/jars/hadoop-aws-${HADOOP_AWS_VERSION}.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar && \
  echo "$HADOOP_AWS_CHECKSUM ${SPARK_HOME}/jars/hadoop-aws-${HADOOP_AWS_VERSION}.jar" | sha256sum -c -
