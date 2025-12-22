from datetime import datetime, timedelta

from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.sdk import DAG
from custom.operators.api_check_operator import WaitForStartedStatusSensor

with DAG(
    dag_id="example_custom_sensor_async",
    schedule=None,
    start_date=datetime.now() - timedelta(minutes=20),
    catchup=False
) as dag:

    wait = WaitForStartedStatusSensor(task_id="wait")

    finish = EmptyOperator(task_id="finish")
    wait >> finish
