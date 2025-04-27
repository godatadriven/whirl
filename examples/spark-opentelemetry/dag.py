import os
from datetime import datetime, timedelta
from pprint import pformat

from airflow import DAG
from airflow.utils.context import Context as AirflowContext
from airflow.operators.sql import SQLCheckOperator
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator

THIS_DIRECTORY = os.path.dirname(os.path.abspath(__file__)) + '/'
SPARK_DIRECTORY = THIS_DIRECTORY + 'spark/'
DAGRUN_EXECUTION_DATE = "{{ next_execution_date.strftime('%Y%m%d') }}"

default_args = {
    'owner': 'whirl',
    'start_date': datetime.now() - timedelta(days=2),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

BUCKET = os.environ.get('DEMO_BUCKET')
FILE = 's3://{bucket}/input/data/demo/spark/{date}/'.format(
    bucket=BUCKET,
    date=DAGRUN_EXECUTION_DATE
)
TABLE = 'demo'


def compose_traceparent(context: AirflowContext) -> str:
    """Obtains the Trace ID and Span ID of the ongoing Task Instance.

    This function can only be called during task execution. The ongoing OpenTelemetry Context is not included in the
    Airflow Context, but Airflow uses a deterministic function to generate the required IDs out of the DagRun and
    TaskInstance. This function uses the same and outputs a string in the format of a W3C ``traceparent`` header.

    :param context: Airflow task execution context.
    :return: Traceparent header value.
    """
    from airflow.traces import NO_TRACE_ID
    from airflow.traces.utils import gen_trace_id, gen_span_id
    version = "00"
    trace_id = gen_trace_id(context['dag_run'])
    span_id = gen_span_id(context['task_instance'])
    flags = "00" if trace_id == NO_TRACE_ID else "01"
    return f"{version}-{trace_id}-{span_id}-{flags}"


class OtelSparkSubmitOperator(SparkSubmitOperator):
    """
    This hook is a wrapper around the spark-submit operator to provide the otel parent id.
    """
    def execute(self, context: AirflowContext):
        """
        Call the SparkSubmitHook to run the provided spark job
        """
        spark_extra_conf = {
            "spark.com.xebia.data.spot.traceparent": compose_traceparent(context)
        }
        self._log.info("Adding Spark configuration: " + pformat(spark_extra_conf))
        self.conf.update(spark_extra_conf)
        super().execute(context)

dag = DAG(dag_id='spark-s3-to-postgres',
          default_args=default_args,
          schedule_interval='@daily',
          dagrun_timeout=timedelta(seconds=120))

spark_conf = {
    'spark.hadoop.fs.s3a.impl': 'org.apache.hadoop.fs.s3a.S3AFileSystem',
    'spark.hadoop.fs.s3a.access.key': os.environ.get('AWS_ACCESS_KEY_ID', ''),
    'spark.hadoop.fs.s3a.secret.key': os.environ.get('AWS_SECRET_ACCESS_KEY', ''),
    'spark.hadoop.fs.s3a.endpoint': "{}:{}".format(os.environ.get('AWS_SERVER', ''), os.environ.get('AWS_PORT', '')),
    'spark.hadoop.fs.s3a.connection.ssl.enabled': 'false',
    'spark.hadoop.fs.s3a.path.style.access': 'true',
    'spark.hadoop.fs.s3.impl': 'org.apache.hadoop.fs.s3a.S3AFileSystem',
    'spark.hadoop.fs.s3a.aws.credentials.provider': 'org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider',
    'spark.extraListeners': 'com.xebia.data.spot.TelemetrySparkListener',
    'spark.otel.service.name': 'Apache Spark',
}

spark = OtelSparkSubmitOperator(
    task_id='fetch_csv_from_s3_and_update_postgres',
    dag=dag,
    conf=spark_conf,
    application='{spark_dir}/s3topostgres.py'.format(spark_dir=SPARK_DIRECTORY),
    application_args=[
        '-f', FILE,
        '-t', TABLE
    ]
)

check = SQLCheckOperator(
    task_id='check_demo_contains_data',
    conn_id='local_pg',
    sql='SELECT COUNT(*) FROM {table}'.format(table=TABLE),
    dag=dag
)

spark >> check
