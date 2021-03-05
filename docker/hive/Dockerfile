FROM openjdk:8-jre

# Bootstrap
RUN apt-get update \
 && apt-get install -y libpostgresql-jdbc-java procps libsasl2-modules libsasl2-dev \
 && rm -rf /var/lib/apt/lists/*

# Install Apache Hadoop
ENV HADOOP_VERSION=3.2.0
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/conf
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl -L \
  "https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
    | tar xvfz - -C /opt/ \
  && rm -rf $HADOOP_HOME/share/doc \
  && chown -R root:root $HADOOP_HOME \
  && mkdir -p $HADOOP_HOME/logs \
  && mkdir -p $HADOOP_CONF_DIR \
  && chmod 777 $HADOOP_CONF_DIR \
  && chmod 777 $HADOOP_HOME/logs

# Install Apache Hive
ENV HIVE_VERSION=3.1.2
ENV HIVE_HOME=/opt/apache-hive-$HIVE_VERSION-bin
ENV HIVE_CONF_DIR=$HIVE_HOME/conf
ENV PATH $PATH:$HIVE_HOME/bin
RUN curl -L \
  "https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz" \
    | tar xvfz - -C /opt/ \
  && chown -R root:root $HIVE_HOME \
  && mkdir -p $HIVE_HOME/hcatalog/var/log \
  && mkdir -p $HIVE_HOME/var/log \
  && mkdir -p /data/hive/ \
  && mkdir -p $HIVE_CONF_DIR \
  && chmod 777 $HIVE_HOME/hcatalog/var/log \
  && chmod 777 $HIVE_HOME/var/log

# Configure
ADD hive-site.xml core-site.xml $HIVE_CONF_DIR/
ADD init-hive.sh /

ENV SDK_AWS_VERSION=1.11.563
ENV HADOOP_AWS_VERSION=3.2.0

ENV SDK_AWS_CHECKSUM=b323857424e133b44c1156a184dc3a83fa152b656f2e320a71b5637a854822d5
ENV HADOOP_AWS_CHECKSUM=ceac8724f8bb47d2f039eaecf4ee147623b46e4bbf26ddf73a9bb8808743655e

RUN curl -o $HIVE_HOME/lib/aws-java-sdk-bundle-$SDK_AWS_VERSION.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/$SDK_AWS_VERSION/aws-java-sdk-bundle-$SDK_AWS_VERSION.jar && \
  echo "$SDK_AWS_CHECKSUM $HIVE_HOME/lib/aws-java-sdk-bundle-$SDK_AWS_VERSION.jar" | sha256sum -c -

RUN curl -o $HIVE_HOME/lib/hadoop-aws-$HADOOP_AWS_VERSION.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar && \
  echo "$HADOOP_AWS_CHECKSUM $HIVE_HOME/lib/hadoop-aws-$HADOOP_AWS_VERSION.jar" | sha256sum -c -

RUN chmod +x /init-hive.sh

EXPOSE 9083

ENTRYPOINT [ "/init-hive.sh" ]