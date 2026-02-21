# -*- coding: utf-8 -*-

from datetime import timedelta

import pendulum
from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG
from custom_plugins.timetable.fullmoon import FullMoonTimetable

args = {
    'owner': 'airflow',
    'start_date': pendulum.today('UTC').add(days=-3),
}

with DAG(
    dag_id='example_timetable',
    default_args=args,
    schedule=FullMoonTimetable(),
    dagrun_timeout=timedelta(minutes=60),
) as dag:
    BashOperator(
        task_id='echo_interval',
        bash_command='echo "{{ data_interval_start }} - {{ data_interval_end }}"'
    )
