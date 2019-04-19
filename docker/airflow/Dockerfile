FROM openjdk:8-jre-slim

ENV AIRFLOW_BUILD_DEPS="freetds-dev libkrb5-dev libssl-dev libffi-dev libpq-dev git"
ENV AIRFLOW_APT_DEPS="libsasl2-dev freetds-bin build-essential default-libmysqlclient-dev apt-utils curl rsync netcat locales"

ENV CONDA_DIR /opt/miniconda
ENV CONDA_VERSION 3-4.5.12
ENV CONDA_CHECKSUM=e5e5b4cd2a918e0e96b395534222773f7241dc59d776db1b9f7fedfcb489157a
ARG PYTHON_VERSION=3.6
ENV PYTHON_VERSION=${PYTHON_VERSION}

ENV HADOOP_VERSION=2.7
ENV PY4J_VERSION=0.10.7
ENV PYTHONPATH=$SPARK_HOME/python/lib/py4j-$PY4J_VERSION-src.zip:$SPARK_HOME/python/:$PYTHONPATH
ENV SPARK_CHECKSUM=c93c096c8d64062345b26b34c85127a6848cff95a4bb829333a06b83222a5cfa
ENV SPARK_HOME /usr/spark
ENV SPARK_MAJOR_VERSION 2
ENV SPARK_VERSION=2.4.0

ENV WHIRL_SETUP_FOLDER=/etc/airflow/whirl.setup.d
ENV AIRFLOW_VERSION=1.10.2
ENV AIRFLOW_LOG_LEVEL DEBUG
ENV AIRFLOW_HOME /usr/local/airflow
ENV AIRFLOW_GPL_UNIDECODE=yes
ENV SLUGIFY_USES_TEXT_UNIDECODE=yes

RUN update-ca-certificates -f \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --reinstall build-essential \
  && apt-get install -y --allow-unauthenticated \
     software-properties-common \
     wget \
     curl \
     dnsutils \
     vim \
     git \
     default-libmysqlclient-dev \
     gcc \
     ${AIRFLOW_BUILD_DEPS} \
     ${AIRFLOW_APT_DEPS} \
  && apt-get clean

# Spark
RUN cd /usr/ \
    && wget http://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz \
    && echo "$SPARK_CHECKSUM spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz" | sha256sum -c - \
    && tar xzf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz \
    && rm spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz \
    && mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION spark

RUN mkdir -p /usr/spark/work/ && \
    chmod -R 777 /usr/spark/work/

ENV PATH=$PATH:$SPARK_HOME/bin/

# Miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda$CONDA_VERSION-Linux-x86_64.sh -O miniconda.sh && \
    echo "$CONDA_CHECKSUM miniconda.sh" | sha256sum -c - && \
    chmod a+x miniconda.sh && \
    ./miniconda.sh -b -p $CONDA_DIR && \
    rm ./miniconda.sh

ENV PATH="$CONDA_DIR/bin/":$PATH
ENV PIP_CONFIG_FILE=/opt/.pip/pip.conf

RUN conda update conda && conda install python=$PYTHON_VERSION -y --force

RUN pip install apache-airflow[all]==${AIRFLOW_VERSION} && \
    mkdir -p $AIRFLOW_HOME/dags

ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
ENV AIRFLOW__CORE__LOGGING_LEVEL=${AIRFLOW_LOG_LEVEL}
ENV AIRFLOW__WEBSERVER__EXPOSE_CONFIG=True

RUN mkdir -p ${WHIRL_SETUP_FOLDER}/env.d && \
    mkdir -p ${WHIRL_SETUP_FOLDER}/dag.d

EXPOSE 5000

ADD entrypoint.sh delete_all_airflow_connections.py /
ADD includes /etc/airflow/functions

ENTRYPOINT "/entrypoint.sh"
