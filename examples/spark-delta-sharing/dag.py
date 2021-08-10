import os
from datetime import timedelta, datetime
from airflow import DAG
from airflow.contrib.operators.spark_submit_operator import SparkSubmitOperator
from airflow.operators.python_operator import PythonOperator

import delta_sharing
import logging


def _check_sharing_pandas(templates_dict, **context):
    logging.basicConfig(level=logging.DEBUG)

    profile_file = "file:///opt/airflow/delta.profile"

    client = delta_sharing.SharingClient(profile_file)
    print(client.list_all_tables())

    table_url = profile_file + f"#airflow.spark.{templates_dict['table']}"

    sharingDF = delta_sharing.load_as_pandas(table_url)
    print(sharingDF.head())

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
HIVE_DW_BUCKET = os.environ.get('HIVE_DW_BUCKET')
FILE = 's3://{bucket}/input/data/demo/spark/{date}/'.format(
    bucket=BUCKET,
    date=DAGRUN_EXECUTION_DATE
)
DELTA_TABLE = 's3://{bucket}/output/data/demo/spark/cars/'.format(
    bucket=BUCKET)
DELTA_NP_TABLE = 's3://{bucket}/output/data/demo/spark/cars-all/'.format(
    bucket=BUCKET)

dag = DAG(dag_id='spark-s3-to-delta-with-delta-sharing',
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
    'spark.hadoop.fs.s3.impl': 'org.apache.hadoop.fs.s3a.S3AFileSystem',
    'spark.hadoop.fs.s3a.multipart.size': '104857600',
    'spark.jars.packages': 'io.delta:delta-core_2.12:1.0.0,io.delta:delta-sharing-spark_2.12:0.1.0',
    'spark.sql.extensions': 'io.delta.sql.DeltaSparkSessionExtension',
    'spark.sql.catalog.spark_catalog': 'org.apache.spark.sql.delta.catalog.DeltaCatalog'
}

spark_sharing_conf = {
    'spark.jars.packages': 'io.delta:delta-core_2.12:1.0.0,io.delta:delta-sharing-spark_2.12:0.1.0',
    'spark.sql.extensions': 'io.delta.sql.DeltaSparkSessionExtension',
    'spark.sql.catalog.spark_catalog': 'org.apache.spark.sql.delta.catalog.DeltaCatalog'
}

spark = SparkSubmitOperator(
    task_id='fetch_csv_from_s3_and_save_as_delta',
    dag=dag,
    conf=spark_conf,
    application='{spark_dir}/s3todelta.py'.format(spark_dir=SPARK_DIRECTORY),
    application_args=[
        '-i', FILE,
        '-o', DELTA_TABLE
    ]
)

spark_np = SparkSubmitOperator(
    task_id='fetch_csv_from_s3_and_save_as_delta-nonpartiotioned',
    dag=dag,
    conf=spark_conf,
    application='{spark_dir}/s3todelta-nonpartitioned.py'.format(spark_dir=SPARK_DIRECTORY),
    application_args=[
        '-i', FILE,
        '-o', DELTA_NP_TABLE
    ]
)

delta = SparkSubmitOperator(
    task_id='read_through_delta_sharing',
    dag=dag,
    conf=spark_sharing_conf,
    application='{spark_dir}/readdeltasharing.py'.format(spark_dir=SPARK_DIRECTORY),
    application_args=[
        '-s', 'spark',
        '-t', 'cars'
    ]
)

delta_np = SparkSubmitOperator(
    task_id='read_through_delta_sharing_non_partitioned',
    dag=dag,
    conf=spark_sharing_conf,
    application='{spark_dir}/readdeltasharing.py'.format(spark_dir=SPARK_DIRECTORY),
    application_args=[
        '-s', 'spark',
        '-t', 'cars-all'
    ]
)

pandas_share_cars = PythonOperator(
    task_id="pandas_share_cars",
    python_callable=_check_sharing_pandas,
    templates_dict={"table": "cars"},
    provide_context=True,
    dag=dag,
)

pandas_share_cars_np = PythonOperator(
    task_id="pandas_share_cars_np",
    python_callable=_check_sharing_pandas,
    templates_dict={"table": "cars-all"},
    provide_context=True,
    dag=dag,
)

spark >> delta >> pandas_share_cars
spark_np >> delta_np >> pandas_share_cars_np
