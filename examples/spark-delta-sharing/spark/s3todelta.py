import argparse
from pyspark.sql import SparkSession
from pyspark.sql.functions import current_date


def run_job(spark, input_path, output_path):
    df = spark.read.json(input_path)
    partitioned_df = df.withColumn('date', current_date())
    partitioned_df.write.format("delta").partitionBy('date').mode("overwrite").save(output_path)


if __name__ == "__main__":
    # parse the parameters
    parser = argparse.ArgumentParser(description='S3 to Delta Spark Job')
    parser.add_argument('-i', dest='input_path', action='store')
    parser.add_argument('-o', dest='output_path', action='store')

    arguments = parser.parse_args()

    spark = SparkSession.builder \
        .getOrCreate()

    run_job(spark, arguments.input_path, arguments.output_path)

    spark.stop()
