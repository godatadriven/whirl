import os
from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.empty import EmptyOperator

from cosmos.operators.docker import DbtRunDockerOperator

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

THIS_DIRECTORY = os.path.dirname(os.path.abspath(__file__)) + '/'
DBT_DIRECTORY = THIS_DIRECTORY + 'dbt'
# DBT_IMAGE = "registry:5000/dbt-project:latest"
# connect through localhost since we use the hosts docker daemon
DBT_IMAGE = "localhost:3632/dbt-project:latest"

with DAG(dag_id='whirl-dbt-in-docker-athena-glue',
          default_args=default_args,
          schedule=None,
          dagrun_timeout=timedelta(seconds=120)):

    preprocess = EmptyOperator(task_id="some-preprocessing")

    dbt_raw_to_source = DbtRunDockerOperator(
        task_id="dbt-raw-to-source",
        project_dir=DBT_DIRECTORY,
        image=DBT_IMAGE,
        network_mode="host",
        mount_tmp_dir=False,
        environment={
            "AWS_ACCESS_KEY_ID": os.getenv("AWS_ACCESS_KEY_ID"),
            "AWS_SECRET_ACCESS_KEY": os.getenv("AWS_SECRET_ACCESS_KEY"),
            "AWS_ENDPOINT_URL": "http://localhost:4566/", # Container is running on host machine so use localhost to connect to localstack athena
            "AWS_DEFAULT_REGION": os.getenv("AWS_DEFAULT_REGION"),
        }
    )

    postprocess = EmptyOperator(task_id="some-postprocessing")

    preprocess >> dbt_raw_to_source >> postprocess

