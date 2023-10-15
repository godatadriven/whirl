import os
from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.bash_operator import BashOperator
from airflow.contrib.operators.spark_submit_operator import SparkSubmitOperator
from airflow_dbt_python.operators.dbt import DbtRunOperator, DbtTestOperator

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

THIS_DIRECTORY = os.path.dirname(os.path.abspath(__file__)) + '/'
SPARK_DIRECTORY = THIS_DIRECTORY + 'spark'
DBT_DIRECTORY = THIS_DIRECTORY + 'dbt'
BUCKET = os.environ.get('DBT_BUCKET')
HIVE_DW_BUCKET = os.environ.get('HIVE_DW_BUCKET')
FILE = 's3://{bucket}/input/data/dbt/{{{{ ds_nodash }}}}/flights_data.zip'.format(
    bucket=BUCKET
)

spark_conf = {
    'spark.sql.catalogImplementation': 'hive',
    'spark.hadoop.hive.metastore.uris': 'thrift://hive:9083',
    'spark.hadoop.fs.defaultFS': "s3a://{}".format(HIVE_DW_BUCKET),
    'spark.hadoop.fs.s3a.impl': 'org.apache.hadoop.fs.s3a.S3AFileSystem',
    'spark.hadoop.fs.s3a.access.key': os.environ.get('AWS_ACCESS_KEY_ID', ''),
    'spark.hadoop.fs.s3a.secret.key': os.environ.get('AWS_SECRET_ACCESS_KEY', ''),
    'spark.hadoop.fs.s3a.endpoint': "{}:{}".format(os.environ.get('AWS_SERVER', ''), os.environ.get('AWS_PORT', '')),
    'spark.hadoop.fs.s3a.connection.ssl.enabled': 'false',
    'spark.hadoop.fs.s3a.path.style.access': 'true',
    'spark.hadoop.fs.s3.impl': 'org.apache.hadoop.fs.s3a.S3AFileSystem',
    'spark.hadoop.fs.s3a.multipart.size': '104857600',
    'spark.hadoop.fs.s3a.aws.credentials.provider': 'org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider'
}

dag = DAG(dag_id='whirl-dbt-spark-example',
          default_args=default_args,
          schedule_interval='@once',
          dagrun_timeout=timedelta(seconds=120))

get_file = BashOperator(task_id="get_file", bash_command="mkdir -p /tmp/flights_data && aws s3 cp {} /tmp/flights_data/ && unzip -o /tmp/flights_data/flights_data.zip -d /tmp/flights_data/extract".format(FILE), dag=dag)

put_airports_file = BashOperator(task_id="put_airports_file", bash_command="aws s3 cp /tmp/flights_data/extract/flights_data/airports.csv s3://{}/csv/".format(BUCKET), dag=dag)

put_flights_file = BashOperator(task_id="put_flights_file", bash_command="aws s3 cp /tmp/flights_data/extract/flights_data/flights.csv s3://{}/csv/".format(BUCKET), dag=dag)

put_carriers_file = BashOperator(task_id="put_carriers_file", bash_command="aws s3 cp /tmp/flights_data/extract/flights_data/carriers.csv s3://{}/csv/".format(BUCKET), dag=dag)

load_airports = SparkSubmitOperator(
    task_id='fetch_airports_csv_from_s3_and_store_as_hive',
    dag=dag,
    conf=spark_conf,
    driver_memory='1G',
    executor_memory='1G',
    executor_cores=1,
    num_executors=2,
    application='{spark_dir}/s3tohive.py'.format(spark_dir=SPARK_DIRECTORY),
    application_args=[
        '-f', 's3://dbt-s3-output/csv/airports.csv',
        '-t', 'airports'
    ]
)

load_carriers = SparkSubmitOperator(
    task_id='fetch_carriers_csv_from_s3_and_store_as_hive',
    dag=dag,
    conf=spark_conf,
    driver_memory='1G',
    executor_memory='1G',
    executor_cores=1,
    num_executors=2,
    application='{spark_dir}/s3tohive.py'.format(spark_dir=SPARK_DIRECTORY),
    application_args=[
        '-f', 's3://dbt-s3-output/csv/carriers.csv',
        '-t', 'carriers'
    ]
)

load_flights = SparkSubmitOperator(
    task_id='fetch_flights_csv_from_s3_and_store_as_hive',
    dag=dag,
    conf=spark_conf,
    driver_memory='1G',
    executor_memory='1G',
    executor_cores=1,
    num_executors=2,
    application='{spark_dir}/s3tohive.py'.format(spark_dir=SPARK_DIRECTORY),
    application_args=[
        '-f', 's3://dbt-s3-output/csv/flights.csv',
        '-t', 'flights_data'
    ]
)

dbt_run = DbtRunOperator(
    task_id='dbt_run',
    project_dir=DBT_DIRECTORY,
    profiles_dir=DBT_DIRECTORY,
    target='hive',
    dag=dag
)


dbt_test = DbtTestOperator(
    task_id='dbt_test',
    project_dir=DBT_DIRECTORY,
    profiles_dir=DBT_DIRECTORY,
    target='hive',
    dag=dag
)

get_file >> [ put_airports_file, put_flights_file, put_carriers_file ]
put_airports_file >> load_airports
put_carriers_file >> load_carriers
put_flights_file >> load_flights

[ load_airports, load_carriers, load_flights ] >> dbt_run >> dbt_test

