#!/usr/bin/env bash

echo "======================================"
echo "== Configure SSH ====================="
echo "======================================"

airflow connections -a --conn_id local_ssh --conn_type SSH --conn_host localhost --conn_login airflow --conn_port 22

# Enable SSH to localhost and install postgresql-client
mkdir -p ${HOME}/.ssh
rm -f ${HOME}/.ssh/id_rsa*
sudo apt-get update
sudo apt-get install -y openssh-client openssh-server
ssh-keygen -t rsa -f ${HOME}/.ssh/id_rsa -q -N ""
cat ${HOME}/.ssh/id_rsa.pub >> ${HOME}/.ssh/authorized_keys
chmod og-wx ${HOME}/.ssh/authorized_keys
sudo sh -c 'echo "ALL: localhost" >> /etc/hosts.allow'

sudo service ssh restart
ssh-keyscan -H localhost >> ${HOME}/.ssh/known_hosts
