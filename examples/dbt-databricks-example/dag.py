import os
from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.bash_operator import BashOperator
from airflow_dbt.operators.dbt_operator import DbtRunOperator, DbtTestOperator, DbtSeedOperator

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

THIS_DIRECTORY = os.path.dirname(os.path.abspath(__file__)) + '/'
SPARK_DIRECTORY = THIS_DIRECTORY + 'spark'
DBT_DIRECTORY = THIS_DIRECTORY + 'dbt-chris-daniel-misja'
BUCKET = os.environ.get('DBT_BUCKET')
FILE = 's3://{bucket}/input/data/dbt/{{{{ ds_nodash }}}}/flights_data.zip'.format(
    bucket=BUCKET
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

get_file = BashOperator(task_id="get_file", bash_command="""
    mkdir -p /tmp/flights_data && 
    aws s3 cp {} /tmp/flights_data/ &&
    unzip -o /tmp/flights_data/flights_data.zip -d /tmp/flights_data/extract""".format(FILE),
                        dag=dag
                        )

seed_dbt = DbtSeedOperator(
    task_id='seed_dbt',
    dag=dag,
    dir=DBT_DIRECTORY,
    profiles_dir=DBT_DIRECTORY,
    select="airports"
)

run_dbt = DbtRunOperator(
    task_id='run_dbt',
    dag=dag,
    dir=DBT_DIRECTORY,
    profiles_dir=DBT_DIRECTORY
)

test_dbt = DbtTestOperator(
    task_id='test_dbt',
    dag=dag,
    dir=DBT_DIRECTORY,
    profiles_dir=DBT_DIRECTORY
)

get_file >> seed_dbt >> run_dbt >> test_dbt
