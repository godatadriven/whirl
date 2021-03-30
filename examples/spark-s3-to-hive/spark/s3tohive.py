import argparse
from pyspark.sql import SparkSession


def run_job(spark, input_path, output_table):
    df = spark.read.json(input_path)
    df.write.saveAsTable(output_table)


if __name__ == "__main__":
    # parse the parameters
    parser = argparse.ArgumentParser(description='S3 to Hive Spark Job')
    parser.add_argument('-f', dest='input_path', action='store')
    parser.add_argument('-t', dest='output_table', action='store')

    arguments = parser.parse_args()

    spark = SparkSession.builder \
        .getOrCreate()

    run_job(spark, arguments.input_path, arguments.output_table)

    spark.stop()
