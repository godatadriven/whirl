from datetime import timedelta, datetime
from airflow import DAG

from airflow.decorators import task
from airflow.hooks.S3_hook import S3Hook

from include.datasets import DEMO_API_DS


default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='single-dataset-consumer',
    default_args=default_args,
    schedule=[DEMO_API_DS],
    dagrun_timeout=timedelta(seconds=120)
):

    @task()
    def s3_store(conn_id, localfile, bucket, path, **context):
        s3hook = S3Hook(conn_id)
        s3hook.load_file(
            localfile,
            output_path,
            bucket_name=bucket,
            replace=True
        )

    s3bucket = "demo-s3-output"
    output_path = "api-store/{{ ds_nodash }}/demo-api.parquet"

    s3_store(conn_id="local_s3", localfile=DEMO_API_DS.uri, bucket=s3bucket, path=output_path)
