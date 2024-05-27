import os
from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.bash_operator import BashOperator

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

THIS_DIRECTORY = os.path.dirname(os.path.abspath(__file__)) + '/'
DBT_DIRECTORY = THIS_DIRECTORY + 'dbt'
BUCKET = os.environ.get('DBT_STAGING_BUCKET')
FILE = 's3://{bucket}/input/data/dbt/{{{{ ds_nodash }}}}/flights_data.zip'.format(
    bucket=BUCKET
)

with DAG(dag_id='whirl-dbt-athena-example',
          default_args=default_args,
          schedule='@once',
          dagrun_timeout=timedelta(seconds=120)):

    get_file = BashOperator(task_id="get_file", bash_command="mkdir -p /tmp/flights_data && aws s3 cp {} /tmp/flights_data/ && unzip -o /tmp/flights_data/flights_data.zip -d /tmp/flights_data/extract".format(FILE))

    put_airports_file = BashOperator(task_id="put_airports_file", bash_command="aws s3 cp /tmp/flights_data/extract/flights_data/airports.csv s3://{}/csv/".format(BUCKET))

    put_flights_file = BashOperator(task_id="put_flights_file", bash_command="aws s3 cp /tmp/flights_data/extract/flights_data/flights.csv s3://{}/csv/".format(BUCKET))

    put_carriers_file = BashOperator(task_id="put_carriers_file", bash_command="aws s3 cp /tmp/flights_data/extract/flights_data/carriers.csv s3://{}/csv/".format(BUCKET))


    get_file >> [ put_airports_file, put_flights_file, put_carriers_file ]

