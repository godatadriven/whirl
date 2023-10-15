ARG AIRFLOW_VERSION=2.7.2
ARG PYTHON_VERSION=3.9
FROM apache/airflow:${AIRFLOW_VERSION}-python${PYTHON_VERSION}

USER root

ARG AIRFLOW_VERSION=2.7.2
ENV AIRFLOW_VERSION=${AIRFLOW_VERSION}
ENV WHIRL_SETUP_FOLDER=/etc/airflow/whirl.setup.d

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mkdir -p "${WHIRL_SETUP_FOLDER}/env.d"
RUN mkdir -p "${WHIRL_SETUP_FOLDER}/dag.d"

RUN chown -R airflow:root "${WHIRL_SETUP_FOLDER}"

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

RUN echo "airflow ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER airflow
EXPOSE 5000

COPY --chown=airflow:root entrypoint.sh /entrypoint-whirl.sh
COPY includes /etc/airflow/functions
COPY pip.conf /home/airflow/.config/pip/pip.conf

ENV PATH="${PATH}:/home/airflow/.local/bin"
ENTRYPOINT ["/entrypoint-whirl.sh"]
CMD ["airflow", "--help"]