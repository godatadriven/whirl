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
cat /opt/airflow/.kubeconfig/kubeconfig-k3s.yaml | sed -e 's/127\.\0\.0\.1/k3s-server/g' > /opt/airflow/.kubeconfig/k3s.yaml

echo "========================="
echo "== Show kubectl config =="
echo "========================="
ls -la /opt/airflow
ls -l /opt/airflow/.kubeconfig/
cat /opt/airflow/.kubeconfig/k3s.yaml
