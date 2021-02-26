FROM openjdk:8-jre

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
  && chmod 777 $HIVE_HOME/var/log && \
  # Install ^&%@#^$&@^$ gcs connector to metastore. If you don't do this you will be
  #  sorry because the spark thrift server will claim it doesn't get the gs:// filepath.
  curl -s -L --url "https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop2-2.0.1.jar" \
    --output $HIVE_HOME/lib/gcs-connector-latest-hadoop2.jar

# Configure
ADD files/hive-site.xml files/core-site.xml $HIVE_CONF_DIR/

ADD files/init-hive.sh /
RUN chmod +x /init-hive.sh

EXPOSE 9083

ENTRYPOINT [ "/init-hive.sh" ]