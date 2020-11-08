#!/usr/bin/env bash
echo "============================"
echo "======== Add java =========="
echo "============================"

sudo apt-get update && sudo apt-get install -y openjdk-11-jre
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

echo "============================"
echo "== Configure Spark config =="
echo "============================"
airflow connections -a \
    --conn_id spark_default \
    --conn_type spark \
    --conn_host local \
    --conn_extra "{\"queue\": \"root.default\"}"

POSTGRES_JDBC_CHECKSUM=7ffa46f8c619377cdebcd17721b6b21ecf6659850179f96fec3d1035cf5a0cdc
HADOOP_AWS_CHECKSUM=acf05db5e92f79b287444c9e6bd71f27f125193c47ef59149460ef02ef73a72c
AWS_SDK_CHECKSUM=ab74b9bd8baf700bbb8c1270c02d87e570cd237af2464bafa9db87ca1401143a

pip install pyspark==${SPARK_VERSION}
export SPARK_HOME=$(python ~/.local/bin/find_spark_home.py)
echo "-------------------------------"
echo "SPARK_HOME set to ${SPARK_HOME}"
echo "-------------------------------"

curl -o ${SPARK_HOME}/jars/aws-java-sdk-1.7.4.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar && \
  echo "$AWS_SDK_CHECKSUM ${SPARK_HOME}/jars/aws-java-sdk-1.7.4.jar" | sha256sum -c -

curl -o ${SPARK_HOME}/jars/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar && \
  echo "$POSTGRES_JDBC_CHECKSUM ${SPARK_HOME}/jars/postgresql-42.2.5.jar" | sha256sum -c -

curl -o ${SPARK_HOME}/jars/hadoop-aws-2.7.4.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.4/hadoop-aws-2.7.4.jar && \
  echo "$HADOOP_AWS_CHECKSUM ${SPARK_HOME}/jars/hadoop-aws-2.7.4.jar" | sha256sum -c -

