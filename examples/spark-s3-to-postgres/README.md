#### Spark S3 to PostgreSQL Example

In this example we use Spark to read data from S3 and store it in a PostgreSQL
table, then verify the result:

1. Mock JSON input data is uploaded to S3;
2. A Spark job (`SparkSubmitOperator`) reads the data from S3 and writes it to a
   PostgreSQL table;
3. A `SQLCheckOperator` runs a `SELECT COUNT(*)` against the table to confirm
   the data was loaded.

The Spark application (`spark/s3topostgres.py`) is configured through the
`spark_conf` in the DAG to talk to the S3 server, and the check uses the
`local_pg` Airflow connection.

This example uses the `postgres-s3-external-spark` environment, which includes
containers for:

 - A S3 server;
 - A PostgreSQL database;
 - A Spark cluster;
 - The core Airflow component.

The environment contains setup scripts in the `whirl.setup.d/` folder:

 - `01_add_mockdata_to_s3.sh` which uploads the mock input data
   (`mock-data/input.json`) to the S3 bucket;
 - `03_install_airflow_providers.sh` which installs the additional Airflow
   providers required by this example.

> **Note:** the `SQLCheckOperator` used here requires Airflow 2.3.0 or higher.
> This is enforced through `MINIMAL_AIRFLOW_VERSION=2.3.0` in the example
> `.whirl.env`.

To run this example:

```bash
$ cd ./examples/spark-s3-to-postgres
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access
the Airflow UI. Manually enable the `spark-s3-to-postgres` DAG and watch the
pipeline run to successful completion.

For a variant that writes to a Hive table instead of PostgreSQL, see the
[spark-s3-to-hive](../spark-s3-to-hive) example.