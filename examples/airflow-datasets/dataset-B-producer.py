from datetime import timedelta, datetime
from airflow import DAG

from airflow.decorators import task

from include.datasets import DEMO_B_DS


default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='dataset-B-producer',
    default_args=default_args,
    schedule=None,
    dagrun_timeout=timedelta(seconds=120)
):

    @task(outlets=[DEMO_B_DS])
    def trigger_dataset(**context):
        print(f"Triggering dataset: {DEMO_B_DS.uri}")
        pass

    trigger_dataset()
