import os
import argparse
from pyspark.sql import SparkSession


def run_job(spark, input_path, output_table):
    df = spark.read.csv(input_path, header=True)

    jdbc_url = "jdbc:postgresql://{0}:{1}/{2}?user={3}&password={4}".format(
        os.environ.get('POSTGRES_HOST'),
        os.environ.get('POSTGRES_PORT'),
        os.environ.get('POSTGRES_DB'),
        os.environ.get('POSTGRES_USER'),
        os.environ.get('POSTGRES_PASSWORD')
    )
    df.write.mode("overwrite").jdbc(jdbc_url, output_table)


if __name__ == "__main__":
    # parse the parameters
    parser = argparse.ArgumentParser(description='S3 to Postgres Spark Job')
    parser.add_argument('-f', dest='input_path', action='store')
    parser.add_argument('-t', dest='output_table', action='store')

    arguments = parser.parse_args()

    spark = SparkSession.builder \
        .getOrCreate()

    run_job(spark, arguments.input_path, arguments.output_table)

    spark.stop()
