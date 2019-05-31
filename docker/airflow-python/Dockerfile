FROM python:3.6-slim as airflow-base

ENV AIRFLOW_BUILD_DEPS="freetds-dev python-dev libkrb5-dev libssl-dev libffi-dev libpq-dev git"
ENV AIRFLOW_APT_DEPS="libsasl2-dev sasl2-bin libsasl2-2 libsasl2-dev libsasl2-modules freetds-bin build-essential default-libmysqlclient-dev apt-utils curl rsync netcat locales"

ENV AIRFLOW_VERSION=1.10.3
ENV AIRFLOW_HOME /usr/local/airflow
ENV AIRFLOW_GPL_UNIDECODE=yes
ENV SLUGIFY_USES_TEXT_UNIDECODE=yes
ENV WHIRL_SETUP_FOLDER=/etc/airflow/whirl.setup.d

RUN mkdir -p /usr/share/man/man1 \
  && update-ca-certificates -f \
  && apt-get update \
  && apt-get install -y --no-install-recommends --reinstall build-essential \
  && apt-get install -y --no-install-recommends --allow-unauthenticated \
     software-properties-common \
     wget \
     dnsutils \
     vim \
     git \
     default-libmysqlclient-dev \
     gcc \
     openjdk-8-jre-headless \
     ${AIRFLOW_BUILD_DEPS} \
     ${AIRFLOW_APT_DEPS} \
     nginx \
     gosu \
     sudo \
  && apt-get clean \
  && apt-get autoremove -yqq --purge \
  && rm -rf /var/cache/apk/* /var/lib/apt/lists/* \
  && (find /usr/share/doc -type f -and -not -name copyright -print0 | xargs -0 -r rm)

RUN mkdir /home/airflow \
    && groupadd airflow \
    && useradd -r -g airflow airflow \
    && chown airflow:airflow /home/airflow \
    && echo "airflow ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/airflow \
    && chmod 0440 /etc/sudoers.d/airflow

FROM airflow-base as main

# Optimizing installation of Cassandra driver
# Speeds up building the image - cassandra driver without CYTHON saves around 10 minutes
ARG CASS_DRIVER_NO_CYTHON="1"
# Build cassandra driver on multiple CPUs
ARG CASS_DRIVER_BUILD_CONCURRENCY="8"

ENV CASS_DRIVER_BUILD_CONCURRENCY=${CASS_DRIVER_BUILD_CONCURRENCY}
ENV CASS_DRIVER_NO_CYTHON=${CASS_DRIVER_NO_CYTHON}

# By default PIP install run without cache to make image smaller
ARG PIP_NO_CACHE_DIR="true"
ENV PIP_NO_CACHE_DIR=${PIP_NO_CACHE_DIR}

RUN pip install --upgrade pip \
    && pip install apache-airflow[all]==${AIRFLOW_VERSION} \
    && mkdir -p ${AIRFLOW_HOME}/dags \
    && chown -R airflow.airflow ${AIRFLOW_HOME}

RUN mkdir -p ${WHIRL_SETUP_FOLDER}/env.d

# Make sure a ssl certificate is generated and configured. Nginx can be configured if needed from now on.
RUN mkdir -p /etc/nginx/ssl \
    && mkdir -p /etc/nginx/conf.d/locations.d \
    && openssl genrsa -des3 -passout pass:p4ssw0rd -out server.pass.key 2048 \
    && openssl rsa -passin pass:p4ssw0rd -in server.pass.key -out /etc/nginx/ssl/server.key \
    && rm server.pass.key \
    && openssl req -new -key /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.csr \
        -subj "/C=NL/ST=Utrecht/L=Utrecht/O=Airflow/OU=IT Department/CN=localhost" \
    && openssl x509 -req -days 3650 -in /etc/nginx/ssl/server.csr -signkey /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt \
    && openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 \
    && cat /etc/nginx/ssl/server.key > /etc/nginx/ssl/server.pem \
    && cat /etc/nginx/ssl/server.crt >> /etc/nginx/ssl/server.pem \
    && ln -s /etc/nginx/ssl/server.crt /etc/ssl/certs/nginx_selfsigned.crt \
    && update-ca-certificates -f

ADD nginx-ssl.conf /etc/nginx/conf.d/

USER airflow

EXPOSE 5000

ADD --chown=airflow:airflow entrypoint.sh delete_all_airflow_connections.py /
ADD includes /etc/airflow/functions

ENV PATH="${PATH}:/home/airflow/.local/bin"
ENTRYPOINT "/entrypoint.sh"
