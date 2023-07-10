ARG SPARK_VERSION=3.4.0
#FROM godatadriven/spark:${SPARK_VERSION}
FROM krisgeus/spark-arm:3.4.0

ENV SDK_AWS_VERSION=1.12.262
ENV HADOOP_AWS_VERSION=3.3.4

ENV SDK_AWS_CHECKSUM=873fe7cf495126619997bec21c44de5d992544aea7e632fdc77adb1a0915bae5
ENV HADOOP_AWS_CHECKSUM=53f9ae03c681a30a50aa17524bd9790ab596b28481858e54efd989a826ed3a4a
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
  echo "spark.hadoop.fs.s3a.multipart.size=104857600" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider" >> ${SPARK_HOME}/conf/spark-defaults.conf
