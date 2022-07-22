# -*- coding: utf-8 -*-

from builtins import range
from datetime import timedelta

from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago

from custom_plugins.timetable.fullmoon import FullMoonTimetable

args = {
    'owner': 'airflow',
    'start_date': days_ago(3),
}

with DAG(
    dag_id='example_timetable',
    default_args=args,
    timetable=FullMoonTimetable(),
    dagrun_timeout=timedelta(minutes=60),
) as dag:
    BashOperator(
        task_id='echo_interval',
        bash_command='echo "{{ data_interval_start }} - {{ data_interval_end }}"'
    )
