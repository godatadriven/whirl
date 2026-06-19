#### DBT + Spark Example (S3 → Hive → dbt)

In this example we are going to:

1. Download a zip with flights data from S3 and unzip it;
2. Upload the extracted `airports`, `carriers` and `flights` CSV files back to
   S3;
3. Use Spark (`SparkSubmitOperator`) to load each CSV into a Hive-backed data
   warehouse on S3;
4. Run [dbt](https://www.getdbt.com/) models on top of those Hive tables to
   build enriched, transformed models;
5. Run the dbt tests to validate the result.

This is the Hive/Spark counterpart of the [dbt-example](../dbt-example): instead
of loading into PostgreSQL it stores the data as Hive tables (via the Hive
metastore) and the dbt project targets the `hive` profile (the dbt Spark
adapter).

This example uses the `s3-external-spark-hive` environment, which includes
containers for:

 - A S3 server;
 - A Hive metastore;
 - A Spark cluster;
 - The core Airflow component.

The dbt project lives in the `dbt/` folder and is orchestrated from Airflow with
the [`airflow-dbt-python`](https://github.com/tomasfarias/airflow-dbt-python)
operators.

The environment contains setup scripts in the `whirl.setup.d/` folder:

 - `01_add_mockdata_to_s3.sh` which uploads the mock flights data
   (`mock-data/flights_data.zip`) to the S3 bucket;
 - `02_add_dbt.sh` which installs dbt with the Spark adapter and the
   `airflow-dbt-python` operators.

There are also `compose.setup.d/` and `compose.teardown.d/` scripts that clean
and then display the dbt log around the run for easier debugging.

To run this example:

```bash
$ cd ./examples/dbt-spark-example
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access
the Airflow UI. Manually enable the `whirl-dbt-spark-example` DAG and watch the
pipeline run to successful completion.