from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.python_operator import PythonOperator
from airflow.hooks.http_hook import HttpHook
from airflow.hooks.S3_hook import S3Hook
import pandas as pd


default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}


def _demo_api_get(conn_id, templates_dict, **context):
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
    df.to_parquet(templates_dict['localfile'])


def _demo_s3_store(conn_id, templates_dict, **context):
    s3hook = S3Hook(conn_id)
    s3hook.load_file(
        templates_dict["localfile"],
        templates_dict["s3_output_path"],
        bucket_name=templates_dict["s3_bucket"],
        replace=True
    )


local_path = "/tmp/whirl-local-api-to-s3-example/demo-api.parquet"
s3bucket = "demo-s3-output"
output_path = "api-store/{{ ds_nodash }}/demo-api.parquet"

dag = DAG(dag_id='whirl-local-api-to-s3-example',
          default_args=default_args,
          schedule_interval='@once',
          dagrun_timeout=timedelta(seconds=120))

api_get = PythonOperator(
    task_id="api_get",
    python_callable=_demo_api_get,
    op_kwargs={
        "conn_id": "local_api",
    },
    templates_dict={"localfile": local_path},
    provide_context=True,
    dag=dag,
)

store_s3 = PythonOperator(
    task_id="store_s3",
    python_callable=_demo_s3_store,
    op_kwargs={
        "conn_id": "local_s3",
    },
    templates_dict={
        "localfile": local_path,
        "s3_bucket": s3bucket,
        "s3_output_path": output_path
    },
    provide_context=True,
    dag=dag
)

api_get >> store_s3
