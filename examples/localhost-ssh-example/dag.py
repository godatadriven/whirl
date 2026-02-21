from datetime import datetime, timedelta

from airflow.providers.ssh.operators.ssh import SSHOperator
from airflow.sdk import DAG

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(dag_id='whirl-local-ssh-example',
          default_args=default_args,
          schedule='@once',
          dagrun_timeout=timedelta(seconds=120))

ssh_copy = SSHOperator(
    ssh_conn_id='local_ssh',
    task_id='test_ssh_operator',
    command="cp /opt/airflow/airflow.cfg /tmp/copied_airflow.cfg",
    dag=dag)
