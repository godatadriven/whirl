import os
from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.empty import EmptyOperator

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

with DAG(dag_id='whirl-dbt-athena-glue',
          default_args=default_args,
          schedule=None,
          dagrun_timeout=timedelta(seconds=120)):

    preprocess = EmptyOperator(task_id="some-preprocessing")

    dbt_raw_to_unified = DbtRunLocalOperator(
        task_id="dbt-raw-to-unified",
        project_dir=DBT_DIRECTORY,
        profile_config=ProfileConfig(
            profile_name="dbt_athena_aws",
            target_name="staging",
            profiles_yml_filepath=f"{DBT_DIRECTORY}/profiles.yml"
        )
    )

    dbt_unified_to_mart = DbtRunLocalOperator(
        task_id="dbt-unified-to-mart",
        project_dir=DBT_DIRECTORY,
        profile_config=ProfileConfig(
            profile_name="dbt_athena_aws",
            target_name="marts",
            profiles_yml_filepath=f"{DBT_DIRECTORY}/profiles.yml"
        )
    )

    postprocess = EmptyOperator(task_id="some-postprocessing")

    preprocess >> dbt_raw_to_unified >> dbt_unified_to_mart >> postprocess

