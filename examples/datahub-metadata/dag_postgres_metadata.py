import os

from sqlalchemy import create_engine
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datahub.ingestion.run.pipeline import Pipeline

pg_conn_id = "local_pg"
pg_db = os.environ["POSTGRES_DB"]
dh_conn_id = "datahub_rest_default"

# We could do this a bit more cleanly
pg_hook = PostgresHook(
    postgres_conn_id=pg_conn_id,
    # The PostgresHook uses schema to determine database
    schema=pg_db,
)
pg_conn = pg_hook.get_connection(pg_conn_id)
dh_conn = pg_hook.get_connection(dh_conn_id)

# The pipeline configuration is similar to the recipe YAML files provided to the CLI tool.
pipeline = Pipeline.create(
    {
        "source": {
            "type": "postgres",
            "config": {
                "username": pg_conn.login,
                "password": pg_conn.password,
                "database": pg_db,
                "host_port": f"{pg_conn.host}:{pg_conn.port}",
            },
        },
        "sink": {
            "type": "datahub-rest",
            "config": {"server": "http://datahub-gms:8080"},
        },
    }
)

# Run the pipeline and report the results.
pipeline.run()
pipeline.pretty_print_summary()
