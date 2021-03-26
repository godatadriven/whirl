import os
from datetime import timedelta, datetime
from airflow import DAG
from airflow.contrib.operators.spark_submit_operator import SparkSubmitOperator
from airflow.operators.check_operator import CheckOperator


THIS_DIRECTORY = os.path.dirname(os.path.abspath(__file__)) + '/'
SPARK_DIRECTORY = THIS_DIRECTORY + 'spark/'
DAGRUN_EXECUTION_DATE = "{{ next_execution_date.strftime('%Y%m%d') }}"

default_args = {
    'owner': 'whirl',
    'start_date': datetime.now() - timedelta(days=2),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

BUCKET = os.environ.get('DEMO_BUCKET')
FILE = 's3://{bucket}/input/data/demo/spark/{date}/'.format(
    bucket=BUCKET,
    date=DAGRUN_EXECUTION_DATE
)
TABLE = 'demo'

dag = DAG(dag_id='spark-s3-to-hive',
          default_args=default_args,
          schedule_interval='@daily',
          dagrun_timeout=timedelta(seconds=120))

spark_conf = {
    'spark.hadoop.fs.s3a.impl': 'org.apache.hadoop.fs.s3a.S3AFileSystem',
    'spark.hadoop.fs.s3a.access.key': os.environ.get('AWS_ACCESS_KEY_ID', ''),
    'spark.hadoop.fs.s3a.secret.key': os.environ.get('AWS_SECRET_ACCESS_KEY', ''),
    'spark.hadoop.fs.s3a.endpoint': "{}:{}".format(os.environ.get('AWS_SERVER', ''), os.environ.get('AWS_PORT', '')),
    'spark.hadoop.fs.s3a.connection.ssl.enabled': 'false',
    'spark.hadoop.fs.s3a.path.style.access': 'true',
    'spark.hadoop.fs.s3.impl': 'org.apache.hadoop.fs.s3a.S3AFileSystem'
}

spark = SparkSubmitOperator(
    task_id='fetch_csv_from_s3_and_update_hive',
    dag=dag,
    conf=spark_conf,
    application='{spark_dir}/s3tohive.py'.format(spark_dir=SPARK_DIRECTORY),
    application_args=[
        '-f', FILE,
        '-t', TABLE
    ]
)

# check = CheckOperator(
#     task_id='check_demo_contains_data',
#     conn_id='local_pg',
#     sql='SELECT COUNT(*) FROM {table}'.format(table=TABLE),
#     dag=dag
# )

# spark >> check
# TODO: Can we use great expectations to do the check here?

spark
