from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.dummy_operator import DummyOperator

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}


dag = DAG(dag_id='whirl-dbt-example',
          default_args=default_args,
          schedule_interval='@once',
          dagrun_timeout=timedelta(seconds=120))

dummy = DummyOperator(task_id="dummy-dbt", dag=dag)