"""
Example DAG demonstrating ``TimeDeltaSensorAsync``, a drop in replacement for ``TimeDeltaSensor`` that
defers and doesn't occupy a worker slot while it waits
"""

from datetime import timedelta, datetime

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.sensors.time_delta import TimeDeltaSensorAsync

with DAG(
    dag_id="example_time_delta_sensor_async",
    schedule_interval=None,
    start_date=datetime.now() - timedelta(minutes=20),
    catchup=False
) as dag:

    wait = TimeDeltaSensorAsync(task_id="wait", delta=timedelta(seconds=120))

    finish = EmptyOperator(task_id="finish")
    wait >> finish