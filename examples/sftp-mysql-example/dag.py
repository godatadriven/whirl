from datetime import timedelta, datetime
from airflow import DAG
from airflow.contrib.operators.sftp_operator import SFTPOperator, SFTPOperation
from airflow.operators.python_operator import PythonOperator
from airflow.hooks.mysql_hook import MySqlHook
import pandas


DAGRUN_EXECUTION_DATE = "{{ ds_nodash }}"

default_args = {
    'owner': 'whirl',
    'start_date': datetime.now() - timedelta(days=2),
    'retries': 1,
    'retry_delay': timedelta(seconds=10),
}

FILE = 'mocked-data-{date}.csv'.format(date=DAGRUN_EXECUTION_DATE)


def ingest_csv_into_mysql(input_csv):
    df = pandas.read_csv(input_csv)
    hook = MySqlHook(mysql_conn_id='mysql_connection')
    df.to_sql(
        name="users",
        if_exists='replace',
        con=hook.get_sqlalchemy_engine()
    )


dag = DAG(dag_id='sftp-mock-file-to-mysql',
          default_args=default_args,
          schedule_interval='@daily',
          dagrun_timeout=timedelta(seconds=120))

sftp = SFTPOperator(
    task_id='fetch_csv_from_sftp',
    ssh_conn_id='ftp_server',
    local_filepath='/tmp/latest_users.csv',
    remote_filepath='/working-dir/{file}'.format(file=FILE),
    operation=SFTPOperation.GET,
    dag=dag
)

# lateset released version of Airflow does not do templating
# in the op_args. This has recently been fixed though:
# https://github.com/apache/airflow/pull/4691
# For now, instead of depending on the templated 'file' variable
# we'll use a static name for the file to load into mysql
csv_to_mysql = PythonOperator(
    task_id='ingest_csv_into_mysql',
    python_callable=ingest_csv_into_mysql,
    op_args=['/tmp/latest_users.csv'],
    dag=dag
)

sftp >> csv_to_mysql
