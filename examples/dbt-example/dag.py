import os
from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.dummy_operator import DummyOperator

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

DAGRUN_EXECUTION_DATE = "{{ next_execution_date.strftime('%Y%m%d') }}"

BUCKET = os.environ.get('DBT_BUCKET')
FILE = 's3://{bucket}/input/data/dbt/{date}/'.format(
    bucket=BUCKET,
    date=DAGRUN_EXECUTION_DATE
)

spark_conf = {
    'spark.hadoop.fs.s3a.impl': 'org.apache.hadoop.fs.s3a.S3AFileSystem',
    'spark.hadoop.fs.s3a.access.key': os.environ.get('AWS_ACCESS_KEY_ID', ''),
    'spark.hadoop.fs.s3a.secret.key': os.environ.get('AWS_SECRET_ACCESS_KEY', ''),
    'spark.hadoop.fs.s3a.endpoint': "{}:{}".format(os.environ.get('AWS_SERVER', ''), os.environ.get('AWS_PORT', '')),
    'spark.hadoop.fs.s3a.connection.ssl.enabled': 'false',
    'spark.hadoop.fs.s3a.path.style.access': 'true',
    'spark.hadoop.fs.s3.impl': 'org.apache.hadoop.fs.s3a.S3AFileSystem'
}

dag = DAG(dag_id='whirl-dbt-example',
          default_args=default_args,
          schedule_interval='@once',
          dagrun_timeout=timedelta(seconds=120))

dummy = DummyOperator(task_id="dummy-dbt", dag=dag)