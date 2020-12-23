#!/usr/bin/env bash
echo "============================"
echo "======== Add java =========="
echo "============================"

sudo apt-get update && sudo apt-get install -y openjdk-11-jre
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

echo "============================"
echo "== Configure Spark configXXX =="
echo "============================"
airflow connections add spark_default \
    --conn-type spark \
    --conn-host "spark://sparkmaster:7077" \
    --conn-extra "{\"queue\": \"root.default\", \"deploy-mode\": \"client\"}"

SDK_AWS_VERSION=1.11.563
HADOOP_AWS_VERSION=3.2.0

POSTGRES_JDBC_CHECKSUM=7ffa46f8c619377cdebcd17721b6b21ecf6659850179f96fec3d1035cf5a0cdc
SDK_AWS_CHECKSUM=b323857424e133b44c1156a184dc3a83fa152b656f2e320a71b5637a854822d5
HADOOP_AWS_CHECKSUM=ceac8724f8bb47d2f039eaecf4ee147623b46e4bbf26ddf73a9bb8808743655e

pip install pyspark==${SPARK_VERSION}
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
