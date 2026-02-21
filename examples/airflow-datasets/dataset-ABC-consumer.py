from datetime import datetime, timedelta

from airflow.sdk import DAG, task
from include.datasets import DEMO_A_DS, DEMO_B_DS, DEMO_C_DS

default_args = {
    'owner': 'whirl',
    'depends_on_past': False,
    'start_date': datetime.now() - timedelta(minutes=20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='dataset-ABC-consumer',
    default_args=default_args,
    schedule=[DEMO_A_DS, DEMO_B_DS, DEMO_C_DS],
    dagrun_timeout=timedelta(seconds=120)
):

    @task
    def echo_trigger(triggering_asset_events=None):
        print(triggering_asset_events)
        print(triggering_asset_events.values())
        print(triggering_asset_events.items())
        if triggering_asset_events:
            for asset, asset_events in triggering_asset_events.items():
                print(f"Asset: {asset.uri}")
                for event in asset_events:
                    print(f"  - Triggered by DAG run: {event.source_dag_id}")
                    print(f"    Timestamp: {event.timestamp}")

    echo_trigger()
