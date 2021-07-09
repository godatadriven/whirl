import argparse
import delta_sharing
from pyspark.sql import SparkSession

def run_job(spark, schema, table):
	profile_file = "file:///opt/airflow/delta.profile"

	client = delta_sharing.SharingClient(profile_file)
	client.list_all_tables()

	table_url = profile_file + "#airflow.{schema}.{table}".format(schema=schema, table=table)

	sharedDF = delta_sharing.load_as_spark(table_url)
	sharedDF.show()

if __name__ == "__main__":
    # parse the parameters
    parser = argparse.ArgumentParser(description='Read through Delta Sharing Spark Job')
    parser.add_argument('-s', dest='schema', action='store')
    parser.add_argument('-t', dest='table', action='store')

    arguments = parser.parse_args()

    spark = SparkSession.builder \
        .getOrCreate()

    run_job(spark, arguments.schema, arguments.table)

    spark.stop()

