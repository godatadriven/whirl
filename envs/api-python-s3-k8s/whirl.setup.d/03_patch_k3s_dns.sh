#!/usr/bin/env bash

echo "======================"
echo "== Install nslookup =="
echo "======================"
sudo apt-get update && sudo apt-get install -y dnsutils


PATCH_FILE=$(mktemp --suffix k8s-patch)

echo "===================================================="
echo "== Determine nodehosts and write to ${PATCH_FILE} =="
echo "===================================================="
echo -e "data:\n  NodeHosts: |\n$(echo -e "$(for host in mockserver postgresdb s3server; do echo -n "$(nslookup -type=a $host | grep Address | awk -F':' '{gsub(/ /, "", $2);printf("%4s%s\n", " ", $2)}' | tail -n1) $host\n"; done)$(/opt/airflow/kubectl --kubeconfig=/opt/airflow/.kubeconfig/k3s.yaml -n kube-system get configmap coredns -o go-template='{{ .data.NodeHosts }}' | awk '{ printf("%4s%s\n", " ", $0)}')" | sort -u)" > ${PATCH_FILE}

echo "=========================================="
echo "== Patch coredns NodeHosts in configmap =="
echo "=========================================="
/opt/airflow/kubectl --kubeconfig=/etc/airflow/whirl.setup.d/config.d/k3s.yaml -n kube-system patch cm coredns --patch-file ${PATCH_FILE}

echo "====================="
echo "== Restart coredns =="
echo "====================="
/opt/airflow/kubectl --kubeconfig=/etc/airflow/whirl.setup.d/config.d/k3s.yaml --wait=false -n kube-system delete pod -l k8s-app=kube-dns


echo "==========================="
echo " Prepare persistent volume "
echo "==========================="
cat <<EOFPV | /opt/airflow/kubectl --kubeconfig=/etc/airflow/whirl.setup.d/config.d/k3s.yaml create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-data
  labels:
    type: local
spec:
  storageClassName: local-path
  capacity:
    storage: 1Gi
  local:
    path: /data/whirl
  persistentVolumeReclaimPolicy: Retain
  accessModes:
    - ReadWriteMany
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - whirl-k3s-master
EOFPV

echo "================================"
echo " Prepare persistent volumeclaim "
echo "================================"
cat <<EOFPVC | /opt/airflow/kubectl --kubeconfig=/etc/airflow/whirl.setup.d/config.d/k3s.yaml create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-path-airflow-worker-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
EOFPVC
