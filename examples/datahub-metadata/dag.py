"""
# Mock API - S3 - postgres

This DAG pulls data from a mock API, stores it on S3 and then pushes it to Postgres
"""

from datetime import timedelta, datetime
from airflow import DAG

from airflow.operators.python_operator import PythonOperator
from airflow.hooks.http_hook import HttpHook
from airflow.hooks.S3_hook import S3Hook
from airflow.providers.postgres.hooks.postgres import PostgresHook

from datahub_provider.entities import Dataset

from sqlalchemy import create_engine
from textwrap import dedent

import pandas as pd

import os

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}


def _demo_api_get(conn_id, templates_dict, **context):
    """
    Fetch data in json format and persist locally.
    :param str conn_id: Airflow connection id for the API
    :param dict templates_dict: Dictionary of variables templated by Airflow
    :param context: Airflow context
    :return:
    """
    http_hook = HttpHook(http_conn_id=conn_id, method="GET")
    response = http_hook.run('')
    df = pd.DataFrame(response.json())
    print(df.head())
    print(df.columns)
    df.to_parquet(templates_dict['localfile'])


def _demo_s3_store(conn_id, templates_dict, **context):
    s3hook = S3Hook(conn_id)
    s3hook.load_file(
        templates_dict["localfile"],
        templates_dict["s3_output_path"],
        bucket_name=templates_dict["s3_bucket"],
        replace=True
    )


def _demo_s3_to_postgress(conn_id, templates_dict, **context):
    """
    Fetch data in json format and persist locally.
    :param str conn_id: Airflow connection id for the API
    :param dict templates_dict: Dictionary of variables templated by Airflow
    :param context: Airflow context
    :return:
    """
    s3hook = S3Hook(conn_id)
    s3_path = f"s3://{templates_dict['s3_bucket']}/{templates_dict['s3_input_path']}"
    print(s3_path)
    df = pd.read_parquet(
        s3_path,
        storage_options={
            "client_kwargs":{"endpoint_url": "http://s3server:4563"}
        },
    )

    # We could do this a bit more cleanly
    pg_hook = PostgresHook(
        postgres_conn_id=templates_dict['pg_conn_id'],
        # The PostgresHook uses schema to determine database
        schema=templates_dict['target_database'],
    )
    conn = pg_hook.get_connection(templates_dict['pg_conn_id'])
    engine = create_engine(f'postgresql://{conn.login}:{conn.password}@{conn.host}:{conn.port}/{conn.schema}')
    df.to_sql(templates_dict['target_table'], engine, if_exists="replace")


local_path = "/tmp/whirl-local-api-to-s3-example/demo-api.parquet"
s3bucket = "demo-s3-output"
output_path = "api-store/{{ ds_nodash }}/demo-api.parquet"

with DAG(
    dag_id='whirl-local-api-s3-postgres',
    default_args=default_args,
    schedule_interval='@once',
    dagrun_timeout=timedelta(seconds=120)
) as dag:
    dag.doc_md = __doc__  # takes docstring from the beginning of the DAG file

    api_get = PythonOperator(
        task_id="api_get",
        python_callable=_demo_api_get,
        op_kwargs={
            "conn_id": "local_api",
        },
        templates_dict={"localfile": local_path},
        provide_context=True,
    )

    api_get.doc_md = dedent(
        """\
    ## api_get Documentation
    You can document your task using the attributes `doc_md` (markdown),
    `doc` (plain text), `doc_rst`, `doc_json`, `doc_yaml` which gets
    rendered in the UI's Task Instance Details page.
    ![img](http://montcs.bloomu.edu/~bobmon/Semesters/2012-01/491/import%20soul.png)
    **Image Credit:** Randall Munroe, [XKCD](https://xkcd.com/license.html)
    """
    )



    store_s3 = PythonOperator(
        task_id="store_s3",
        python_callable=_demo_s3_store,
        op_kwargs={
            "conn_id": "local_s3",
        },
        templates_dict={
            "localfile": local_path,
            "s3_bucket": s3bucket,
            "s3_output_path": output_path
        },
        provide_context=True,
    )

    store_s3.doc_md = dedent(
        """\
    ## store_s3 Documentation
    You can document your task using the attributes `doc_md` (markdown),
    `doc` (plain text), `doc_rst`, `doc_json`, `doc_yaml` which gets
    rendered in the UI's Task Instance Details page.
    ![img](http://montcs.bloomu.edu/~bobmon/Semesters/2012-01/491/import%20soul.png)
    **Image Credit:** Randall Munroe, [XKCD](https://xkcd.com/license.html)
    """
    )

    # todo, specify inlet and outlet datasets

    s3_to_postgres = PythonOperator(
        task_id="s3_to_postgres",
        python_callable=_demo_s3_to_postgress,
        op_kwargs={
            "conn_id": "local_s3",
        },
        templates_dict={
            "s3_bucket": s3bucket,
            "s3_input_path": output_path,
            "pg_conn_id": "local_pg",
            "target_database": os.environ["POSTGRES_DB"],
            "target_table": "api",
        },
        provide_context=True,
        outlets=[Dataset("postgres", "postgresdb.public.api")],
    )

    s3_to_postgres.doc_md = dedent(
        """\
    ## s3_to_postgres Documentation
    You can document your task using the attributes `doc_md` (markdown),
    `doc` (plain text), `doc_rst`, `doc_json`, `doc_yaml` which gets
    rendered in the UI's Task Instance Details page.
    ![img](http://montcs.bloomu.edu/~bobmon/Semesters/2012-01/491/import%20soul.png)
    **Image Credit:** Randall Munroe, [XKCD](https://xkcd.com/license.html)
    """
    )

    api_get >> store_s3 >> s3_to_postgres
