"""
Example DAG demonstrating ``TimeDeltaSensorAsync``, a drop in replacement for ``TimeDeltaSensor`` that
defers and doesn't occupy a worker slot while it waits
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.empty import EmptyOperator
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
