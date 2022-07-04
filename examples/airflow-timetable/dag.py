# -*- coding: utf-8 -*-
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

from builtins import range
from datetime import timedelta

import airflow
from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator

from custom_plugins.timetable.fullmoon import FullMoonTimetable

args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(3),
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
