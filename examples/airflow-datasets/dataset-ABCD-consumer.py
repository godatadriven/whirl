from datetime import timedelta, datetime
from airflow import DAG

from airflow.decorators import task
from airflow.hooks.S3_hook import S3Hook

from include.datasets import DEMO_A_DS, DEMO_B_DS, DEMO_C_DS, DEMO_D_DS


default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='dataset-ABCD-consumer',
    default_args=default_args,
    schedule=[DEMO_A_DS, DEMO_B_DS, DEMO_C_DS, DEMO_D_DS],
    dagrun_timeout=timedelta(seconds=120)
):

    @task
    def echo_trigger(triggering_dataset_events=None):
        for dataset, dataset_list in triggering_dataset_events.items():
            print(dataset, dataset_list)
            print(dataset_list[0].source_dag_run.dag_id)

    echo_trigger()
