#### DBT Example (S3 → Postgres → dbt)

In this example we are going to:

1. Download a zip with flights data from S3 and unzip it;
2. Upload the extracted `airports`, `carriers` and `flights` CSV files back to
   S3;
3. Use Spark (`SparkSubmitOperator`) to load each CSV into a PostgreSQL
   database;
4. Run [dbt](https://www.getdbt.com/) models on top of those tables to build
   enriched, transformed models;
5. Run the dbt tests to validate the result.

dbt is orchestrated from Airflow with the
[`airflow-dbt-python`](https://github.com/tomasfarias/airflow-dbt-python)
`DbtRunOperator` / `DbtTestOperator`. The dbt project lives in the `dbt/` folder
and targets the `airflow` profile (PostgreSQL).

This example uses the `dbt-example` environment, which includes containers for:

 - A S3 server;
 - A PostgreSQL database;
 - A Spark cluster;
 - The core Airflow component.

The environment contains setup scripts in the `whirl.setup.d/` folder:

 - `01_add_mockdata_to_s3.sh` which uploads the mock flights data
   (`mock-data/flights_data.zip`) to the S3 bucket;
 - `02_install_postgres_dbt.sh` which installs the dbt PostgreSQL adapter and
   the `airflow-dbt-python` operators.

There are also `compose.setup.d/` and `compose.teardown.d/` scripts that clean
and then display the dbt log around the run for easier debugging.

To run this example:

```bash
$ cd ./examples/dbt-example
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access
the Airflow UI. Manually enable the `whirl-dbt-example` DAG and watch the
pipeline run to successful completion.

For a variant that loads into Hive (instead of PostgreSQL) and uses the dbt Spark
adapter, see the [dbt-spark-example](../dbt-spark-example).