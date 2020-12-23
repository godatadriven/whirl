#!/usr/bin/env bash

echo "======================================"
echo "== Configure SSH ====================="
echo "======================================"

airflow connections add local_ssh \
    --conn-type SSH \
    --conn-host localhost \
    --conn-login airflow \
    --conn-port 22

# Enable SSH to localhost and install postgresql-client
mkdir -p ${HOME}/.ssh
rm -f ${HOME}/.ssh/id_rsa*
sudo apt-get update
sudo apt-get install -y openssh-client openssh-server
ssh-keygen -t rsa -f ${HOME}/.ssh/id_rsa -q -N "" -m PEM
chmod 600 ${HOME}/.ssh/id_rsa.pub
cat ${HOME}/.ssh/id_rsa.pub >> ${HOME}/.ssh/authorized_keys
chmod og-wx ${HOME}/.ssh/authorized_keys
sudo sh -c 'echo "ALL: localhost" >> /etc/hosts.allow'

sudo service ssh restart
ssh-keyscan -H localhost >> ${HOME}/.ssh/known_hosts
