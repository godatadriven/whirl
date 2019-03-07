#!/usr/bin/env bash

echo "===================="
echo "== Configure SFTP =="
echo "===================="

airflow connections -a --conn_id ftp_server \
                       --conn_type SSH \
                       --conn_host ftp-server \
                       --conn_login $SFTP_USER \
                       --conn_port 22 \
                       --conn_password $SFTP_PASS

mkdir -p ~/.ssh && ssh-keyscan ftp-server >> ~/.ssh/known_hosts

apt-get install -y sshpass
