from datetime import timedelta

from airflow.models import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.utils.dates import days_ago

args = {
    'owner': 'airflow',
    'start_date': days_ago(2),
    'email': 'recipient@example.com',
    'email_on_failure': True,
    'email_on_retry': False,
}


def throw_an_error():
    raise NotImplementedError("""
        Fail because we want to test email to smtp.
        Check localhost:1080 for the mailclient UI
    """)


dag = DAG(
    dag_id='example_external_smtp_configuration',
    default_args=args,
    schedule_interval='0 0 * * *',
    dagrun_timeout=timedelta(minutes=60),
)

run_this_first = DummyOperator(
    task_id='run_this_first',
    dag=dag,
)

fail_at_last = PythonOperator(
    task_id='fail_now',
    python_callable=throw_an_error,
    dag=dag,
)

run_this_first >> fail_at_last
