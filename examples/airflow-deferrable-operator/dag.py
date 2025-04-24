"""
Example DAG demonstrating ``TimeDeltaSensorAsync``, a drop in replacement for ``TimeDeltaSensor`` that
defers and doesn't occupy a worker slot while it waits
"""

from datetime import datetime, timedelta

from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.time.sensors.time_delta import TimeDeltaSensorAsync
from airflow.sdk import DAG

with DAG(
    dag_id="example_time_delta_sensor_async",
    schedule=None,
    start_date=datetime.now() - timedelta(minutes=20),
    catchup=False
) as dag:

    wait = TimeDeltaSensorAsync(task_id="wait", delta=timedelta(seconds=120))

    finish = EmptyOperator(task_id="finish")
    wait >> finish
