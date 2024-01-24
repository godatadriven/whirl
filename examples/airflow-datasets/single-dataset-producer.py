from datetime import timedelta, datetime
from airflow import DAG

from airflow.decorators import task
from airflow.hooks.http_hook import HttpHook
import pandas as pd

from include.datasets import DEMO_API_DS


default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='single-dataset-producer',
    default_args=default_args,
    schedule='@hourly',
    dagrun_timeout=timedelta(seconds=120)
):

    @task(outlets=[DEMO_API_DS])
    def api_get(conn_id, localfile, **context):
        """
        Fetch data in json format and persist locally.
        :param str conn_id: Airflow connection id for the API
        :param dict templates_dict: Dictionary of variables templated by Airflow
        :param context: Airflow context
        :return:
        """
        http_hook = HttpHook(http_conn_id=conn_id, method="GET")
        response = http_hook.run('')
        df = pd.DataFrame(response.json())
        df.to_parquet(localfile)

    api_get(conn_id="local_api", localfile=DEMO_API_DS.uri)
