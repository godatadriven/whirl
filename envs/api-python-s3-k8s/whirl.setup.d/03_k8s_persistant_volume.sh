#!/usr/bin/env bash

echo "==========================="
echo " Prepare persistent volume "
echo "==========================="
cat <<EOFPV | /opt/airflow/kubectl --kubeconfig=/opt/airflow/.kubeconfig/k3s.yaml create -f -
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
cat <<EOFPVC | /opt/airflow/kubectl --kubeconfig=/opt/airflow/.kubeconfig/k3s.yaml create -f -
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
