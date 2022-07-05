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
# set correct permissions
#   ssh directory: 700 (drwx------)
#   public key ( .pub file): 644 (-rw-r--r--)
#   private key ( id_rsa ): 600 (-rw-------)
#   Authorized_keys file: 644 (-rw-r--r--)
#   lastly your home directory should not be writeable by the group or others (at most 755 (drwxr-xr-x) )
mkdir -p ${HOME}/.ssh
rm -f ${HOME}/.ssh/id_rsa*
sudo apt-get update
sudo apt-get install -y openssh-client openssh-server
ssh-keygen -t rsa -f ${HOME}/.ssh/id_rsa -q -N "" -m PEM
chmod 600 ${HOME}/.ssh/id_rsa
chmod 644 ${HOME}/.ssh/id_rsa.pub
cat ${HOME}/.ssh/id_rsa.pub >> ${HOME}/.ssh/authorized_keys
chmod 644 ${HOME}/.ssh/authorized_keys
chmod 700 ${HOME}/.ssh
chmod go-w ${HOME}
sudo sh -c 'echo "ALL: localhost" >> /etc/hosts.allow'

sudo service ssh restart
ssh-keyscan -H localhost >> ${HOME}/.ssh/known_hosts

pip install apache-airflow-providers-ssh
