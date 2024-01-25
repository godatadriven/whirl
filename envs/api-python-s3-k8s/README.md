# Airflow with the KubernetesExecutor

This environment is to test/explain the use of the k8sExecutor in Airflow

## Environment

```
+---------------------+
|                     |
|                     |
|  Postgres           +--------+
|                     |        |
|                     |        |
+----------+----------+        |
           |                   |
+----------+----------+        |     +----------------------------+
|                     |        |     |                            |
|                     |        |     |                            |
|  Airflow            +--------+-----+   K8s cluster (k3s)        |
|                     |        |     |                            |
|                     |        |     |                            |
+---------------------+        |     |       +----------+         |
                               |     |       |          |         |
+---------------------+        +-----+-------+ +--------+--+      |
|                     |        |     |       | |        |  |      |
|                     |        |     |       +-+--------+  |      |
|  S3                 +--------+     |         |  Workers  |      |
|                     |        |     |         +-----------+      |
|                     |        |     |                            |
+---------------------+        |     |                            |
                               |     |                            |
+---------------------+        |     |                            |
|                     |        |     +-----+----------------------+
|                     |        |           |
|  Mockserver         |        |           |
|                     +--------+           |
|                     |                    |
+---------------------+                    |
                                           |
+---------------------+                    |
|                     |                    |
|                     |                    |
|  Docker registry    +--------------------+
|                     |
|                     |
+---------------------+
```

### The moving parts

Airflow is configured to use the KubernetesExecutor, Remote logging to S3 and an external Postgres database. This way also the workers inside the k8s cluster can log to s3 and connect to the external database.

The images that the workers use are stored inside the external docker registry.
For simplicity the dags are copied into the worker images.


The S3 container and mockserver are used from within the DAG to copy data from the rest endpoint to a file in S3.

## Kubernetes executor configuration

The folowing env vars are used to configure Airflow to use the KubernetesExecutor:

```
AIRFLOW__CORE__EXECUTOR=KubernetesExecutor

AIRFLOW__KUBERNETES__IN_CLUSTER=False
AIRFLOW__KUBERNETES__NAMESPACE=default
AIRFLOW__KUBERNETES__CONFIG_FILE=/opt/airflow/.kubeconfig/k3s.yaml
AIRFLOW__KUBERNETES__DELETE_WORKER_PODS=False
AIRFLOW__KUBERNETES__VERIFY_SSL=True
AIRFLOW__KUBERNETES__WORKER_CONTAINER_REPOSITORY=registry:5000/airflow-worker
AIRFLOW__KUBERNETES__WORKER_CONTAINER_TAG=latest
AIRFLOW__KUBERNETES__POD_TEMPLATE_FILE=/etc/airflow/whirl.setup.d/config.d/pod_template.yaml
```

The KubernetesExecutor needs to know how to reach the cluster. This is done through the `AIRFLOW__KUBERNETES__CONFIG_FILE`. This file is created when the k3s master starts and written to a shared volume for simplicity. The airflow startup scripts change the default config file slightly by replacing the `127.0.0.1` ip with the correct hostname on startup.

Furthermore the `AIRFLOW__KUBERNETES__POD_TEMPLATE_FILE` is used to configure the deployment of the worker pods.
The same remote logging config and postgres connection config is used as the Airflow container uses. 
Specifically for the running dag a shared persistent volume is added to the pods to share temporary files with the downstream tasks.

## K3s Kubernetes cluster configuration

To be able to connect to the docker images running S3, Mockserver and the postgres database we need to change the NDS configuration of the k8s cluster a bit. we do this based on the example found in: https://github.com/corneliusludmann/k3s-docker-compose-dns where a custom entrypoint script adds IP tables rules to access Docker's internal DNS 127.0.0.11 from the k8s cluster.

## Kubectl from the Airflow docker container

```bash
/opt/airflow/kubectl  --kubeconfig=/opt/airflow/.kubeconfig/k3s.yaml get pods
```
