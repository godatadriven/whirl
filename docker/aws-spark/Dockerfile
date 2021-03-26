ARG SPARK_VERSION=3.1.1
FROM godatadriven/spark:${SPARK_VERSION}

ENV SDK_AWS_VERSION=1.11.563
ENV HADOOP_AWS_VERSION=3.2.0

ENV SDK_AWS_CHECKSUM=b323857424e133b44c1156a184dc3a83fa152b656f2e320a71b5637a854822d5
ENV HADOOP_AWS_CHECKSUM=ceac8724f8bb47d2f039eaecf4ee147623b46e4bbf26ddf73a9bb8808743655e
ENV POSTGRES_JDBC_CHECKSUM=7ffa46f8c619377cdebcd17721b6b21ecf6659850179f96fec3d1035cf5a0cdc

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean

RUN curl -o /usr/spark/jars/aws-java-sdk-bundle-$SDK_AWS_VERSION.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/$SDK_AWS_VERSION/aws-java-sdk-bundle-$SDK_AWS_VERSION.jar && \
  echo "$SDK_AWS_CHECKSUM /usr/spark/jars/aws-java-sdk-bundle-$SDK_AWS_VERSION.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/hadoop-aws-$HADOOP_AWS_VERSION.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar && \
  echo "$HADOOP_AWS_CHECKSUM /usr/spark/jars/hadoop-aws-$HADOOP_AWS_VERSION.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar && \
  echo "$POSTGRES_JDBC_CHECKSUM /usr/spark/jars/postgresql-42.2.5.jar" | sha256sum -c -

RUN echo "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" > ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3a.connection.ssl.enabled=false" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3a.path.style.access=true" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3a.multipart.size=104857600" >> ${SPARK_HOME}/conf/spark-defaults.conf
