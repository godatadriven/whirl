from datetime import timedelta, datetime
from airflow import DAG
from airflow.contrib.operators.ssh_operator import SSHOperator

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(dag_id='whirl-local-ssh-example',
          default_args=default_args,
          schedule_interval='@once',
          dagrun_timeout=timedelta(seconds=120))

ssh_copy = SSHOperator(
    ssh_conn_id='local_ssh',
    task_id='test_ssh_operator',
    command="cp /usr/local/airflow/airflow.cfg /tmp/copied_airflow.cfg",
    dag=dag)
