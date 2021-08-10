import argparse
from pyspark.sql import SparkSession
from pyspark.sql.functions import current_date


def run_job(spark, input_path, output_path):
    df = spark.read.json(input_path)
    df.write.format("delta").mode("overwrite").save(output_path)


if __name__ == "__main__":
    # parse the parameters
    parser = argparse.ArgumentParser(description='S3 to Delta Non Partitioned Spark Job')
    parser.add_argument('-i', dest='input_path', action='store')
    parser.add_argument('-o', dest='output_path', action='store')

    arguments = parser.parse_args()

    spark = SparkSession.builder \
        .getOrCreate()

    run_job(spark, arguments.input_path, arguments.output_path)

    spark.stop()
