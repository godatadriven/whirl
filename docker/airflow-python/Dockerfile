ARG PYTHON_VERSION=3.6
FROM python:${PYTHON_VERSION}-slim as airflow-base

ENV AIRFLOW_BUILD_DEPS="freetds-dev python-dev libkrb5-dev libssl-dev libffi-dev libpq-dev git"
ENV AIRFLOW_APT_DEPS="libsasl2-dev sasl2-bin libsasl2-2 libsasl2-dev libsasl2-modules freetds-bin build-essential default-libmysqlclient-dev apt-utils curl rsync netcat locales"

ENV AIRFLOW_VERSION=1.10.5
ENV AIRFLOW_HOME /usr/local/airflow
ENV AIRFLOW_GPL_UNIDECODE=yes
ENV SLUGIFY_USES_TEXT_UNIDECODE=yes
ENV WHIRL_SETUP_FOLDER=/etc/airflow/whirl.setup.d

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
     ${AIRFLOW_BUILD_DEPS} \
     ${AIRFLOW_APT_DEPS} \
     nginx \
     gosu \
     sudo \
  && apt-get clean \
  && apt-get autoremove -yqq --purge \
  && rm -rf /var/cache/apk/* /var/lib/apt/lists/* \
  && (find /usr/share/doc -type f -and -not -name copyright -print0 | xargs -0 -r rm)

FROM airflow-base as main_image

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
    && pip install apache-airflow[all_dbs,atlas,async,cassandra,celery,cgroups,cloudant,crypto,dask,databricks,datadog,doc,docker,druid,elasticsearch,gcp_api,github_enterprise,google_auth,hdfs,hive,jdbc,jira,kerberos,ldap,mongo,mssql,mysql,oracle,password,pinot,postgres,qds,rabbitmq,redis,salesforce,samba,sendgrid,segment,slack,snowflake,ssh,statsd,vertica,webhdfs,winrm]=="${AIRFLOW_VERSION}" \
    'pymssql<3.0' \
    && mkdir -p "${AIRFLOW_HOME}/dags"

RUN mkdir -p "${WHIRL_SETUP_FOLDER}/env.d"
RUN mkdir -p "${WHIRL_SETUP_FOLDER}/dag.d"

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

COPY nginx-ssl.conf /etc/nginx/conf.d/

# Harden Image
COPY harden.sh .
RUN chmod +x harden.sh && \
    sh harden.sh airflow

RUN chown -R airflow.airflow ${AIRFLOW_HOME}
USER airflow

EXPOSE 5000

COPY --chown=airflow:airflow entrypoint.sh delete_all_airflow_connections.py /
COPY includes /etc/airflow/functions
COPY pip.conf /home/airflow/.config/pip/pip.conf

ENV PATH="${PATH}:/home/airflow/.local/bin"
ENTRYPOINT ["/entrypoint.sh"]
