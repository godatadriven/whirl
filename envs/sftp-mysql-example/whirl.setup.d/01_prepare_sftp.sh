#!/usr/bin/env bash

echo "===================="
echo "== Configure SFTP =="
echo "===================="

airflow connections add ftp_server \
                       --conn-type SSH \
                       --conn-host ftp-server \
                       --conn-login $SFTP_USER \
                       --conn-port 22 \
                       --conn-password $SFTP_PASS

mkdir -p ${HOME}/.ssh
sudo apt-get update
sudo apt-get install -y openssh-client sshpass
ssh-keyscan ftp-server >> ${HOME}/.ssh/known_hosts
