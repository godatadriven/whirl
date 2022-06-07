#!/usr/bin/env bash

echo "======================"
echo "== Download kubectl =="
echo "======================"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

echo "===================================="
echo "== Download kubectl checksum file =="
echo "===================================="
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

echo "===================="
echo "== Verify kubectl =="
echo "===================="
echo "$(<kubectl.sha256)  kubectl" | sha256sum --check


echo "====================="
echo "== Install kubectl =="
echo "====================="
chmod +x kubectl

echo "=========================="
echo "== Patch kubectl config =="
echo "=========================="
sleep 10
cat /etc/airflow/whirl.setup.d/config.d/kubeconfig-k3s.yaml | sed -e 's/127\.\0\.0\.1/k3s-server/g' > /etc/airflow/whirl.setup.d/config.d/k3s.yaml

echo "========================="
echo "== Show kubectl config =="
echo "========================="
ls -la /etc/airflow/whirl.setup.d/config.d/
ls -l /etc/airflow/whirl.setup.d/config.d/
cat /etc/airflow/whirl.setup.d/config.d/k3s.yaml
