FROM openjdk:8-jre

ENV HADOOP_AWS_CHECKSUM=acf05db5e92f79b287444c9e6bd71f27f125193c47ef59149460ef02ef73a72c
ENV AWS_SDK_CHECKSUM=ab74b9bd8baf700bbb8c1270c02d87e570cd237af2464bafa9db87ca1401143a

# Bootstrap
RUN apt-get update \
 && apt-get install -y libpostgresql-jdbc-java procps libsasl2-modules libsasl2-dev \
 && rm -rf /var/lib/apt/lists/*

# Install Apache Hadoop
ENV HADOOP_VERSION=2.7.4
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
ENV HIVE_VERSION=2.3.7
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

RUN curl -o $HIVE_HOME/lib/aws-java-sdk-1.7.4.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar && \
  echo "$AWS_SDK_CHECKSUM $HIVE_HOME/lib/aws-java-sdk-1.7.4.jar" | sha256sum -c -

RUN curl -o $HIVE_HOME/lib/hadoop-aws-2.7.4.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.4/hadoop-aws-2.7.4.jar && \
  echo "$HADOOP_AWS_CHECKSUM $HIVE_HOME/lib/hadoop-aws-2.7.4.jar" | sha256sum -c -

RUN chmod +x /init-hive.sh

EXPOSE 9083

ENTRYPOINT [ "/init-hive.sh" ]