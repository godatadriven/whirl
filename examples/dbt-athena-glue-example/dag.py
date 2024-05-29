import os
from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.bash_operator import BashOperator
from cosmos import ProfileConfig
from cosmos.operators.local import DbtRunLocalOperator

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

THIS_DIRECTORY = os.path.dirname(os.path.abspath(__file__)) + '/'
DBT_DIRECTORY = THIS_DIRECTORY + 'dbt'
# DBT_IMAGE = "localhost:3632/dbt-project:latest"

# Use cosmos to define the dag from DBT

with DAG(dag_id='whirl-dbt-athena-glue',
          default_args=default_args,
          schedule=None,
          dagrun_timeout=timedelta(seconds=120)):

    dbt_raw_to_source = DbtRunLocalOperator(
        task_id="dbt-raw-to-source",
        project_dir=DBT_DIRECTORY,
        profile_config=ProfileConfig(
            profile_name="dbt_athena_aws",
            target_name="unify",
            profiles_yml_filepath=f"{DBT_DIRECTORY}/profiles.yml"
        )
    )

    dbt_raw_to_source

