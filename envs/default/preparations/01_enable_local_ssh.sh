#!/usr/bin/env bash

echo "======================================"
echo "== Configure SSH ====================="
echo "======================================"

airflow connections -a --conn_id local_ssh --conn_type SSH --conn_host localhost --conn_login root --conn_port 22

# Enable SSH to localhost and install postgresql-client
rm -f /root/.ssh/id_rsa*
ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod og-wx /root/.ssh/authorized_keys
apt-get install -y openssh-client openssh-server
echo "ALL: localhost" >> /etc/hosts.allow

service ssh restart
ssh-keyscan -H localhost >> /root/.ssh/known_hosts
