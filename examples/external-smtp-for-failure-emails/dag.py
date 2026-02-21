from datetime import timedelta

import pendulum
from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.operators.python import PythonOperator
from airflow.sdk import DAG

args = {
    'owner': 'airflow',
    'start_date': pendulum.today('UTC').add(days=-2),
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
    schedule='0 0 * * *',
    dagrun_timeout=timedelta(minutes=60),
)

run_this_first = EmptyOperator(
    task_id='run_this_first',
    dag=dag,
)

fail_at_last = PythonOperator(
    task_id='fail_now',
    python_callable=throw_an_error,
    dag=dag,
)

run_this_first >> fail_at_last
