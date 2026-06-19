#### Spark S3 to Hive Example

In this example we use Spark to read data from S3 and store it in a Hive table:

1. Mock JSON input data is uploaded to S3;
2. A Spark job (`SparkSubmitOperator`) reads the data from S3 and writes it to a
   Hive-backed table on S3 (via the Hive metastore).

The Spark application (`spark/s3tohive.py`) is configured through the
`spark_conf` in the DAG to talk to both the S3 server and the Hive metastore
(`thrift://hive:9083`).

This example uses the `s3-external-spark-hive` environment, which includes
containers for:

 - A S3 server;
 - A Hive metastore;
 - A Spark cluster;
 - The core Airflow component.

The environment contains a setup script in the `whirl.setup.d/` folder:

 - `01_add_mockdata_to_s3.sh` which uploads the mock input data
   (`mock-data/input.json`) to the S3 bucket.

To run this example:

```bash
$ cd ./examples/spark-s3-to-hive
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access
the Airflow UI. Manually enable the `spark-s3-to-hive` DAG and watch the
pipeline run to successful completion.

For a variant that writes to PostgreSQL (and adds a row-count check) instead of
Hive, see the [spark-s3-to-postgres](../spark-s3-to-postgres) example.