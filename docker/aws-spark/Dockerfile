ARG SPARK_VERSION=latest
FROM godatadriven/spark:${SPARK_VERSION}

ENV POSTGRES_JDBC_CHECKSUM=7ffa46f8c619377cdebcd17721b6b21ecf6659850179f96fec3d1035cf5a0cdc
ENV HADOOP_AWS_CHECKSUM=acf05db5e92f79b287444c9e6bd71f27f125193c47ef59149460ef02ef73a72c
ENV AWS_SDK_CHECKSUM=ab74b9bd8baf700bbb8c1270c02d87e570cd237af2464bafa9db87ca1401143a

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean

RUN curl -o /usr/spark/jars/aws-java-sdk-1.7.4.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar && \
  echo "$AWS_SDK_CHECKSUM /usr/spark/jars/aws-java-sdk-1.7.4.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar && \
  echo "$POSTGRES_JDBC_CHECKSUM /usr/spark/jars/postgresql-42.2.5.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/hadoop-aws-2.7.4.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.4/hadoop-aws-2.7.4.jar && \
  echo "$HADOOP_AWS_CHECKSUM /usr/spark/jars/hadoop-aws-2.7.4.jar" | sha256sum -c -

RUN echo "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" > ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3a.connection.ssl.enabled=false" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3a.path.style.access=true" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" >> ${SPARK_HOME}/conf/spark-defaults.conf
