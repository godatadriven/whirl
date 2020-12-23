# FFFFF - dbt Edition

Based off of [a blogpost](https://godatadriven.com/blog/tutorial-for-dbt-analytics-engineering-made-easy/) by Henk Griffioen.

Building data warehouses and doing analytics is still an unsolved problem at many companies.
Luckily, life is getting easier in the current age of [~~ETL~~ ELT](https://www.guru99.com/etl-vs-elt.html).
Cloud providers provide scalable databases like Snowflake and BigQuery, there is less work in loading data with tools like [Stitch](http://stitchdata.com/), and there are many BI tools.
dbt is an analytics engineering tool and is one of the pieces of this puzzle.

dbt helps with the transformation phase: it aims to "enable data analysts and engineers to transform data in their warehouses more effectively".
In the last years, the gap between data engineers and data analysts has become bigger.
Engineers are using more complex tools and write, for instance, data pipelines using Apache Spark in Scala.
On the other hand, analysts still prefer SQL and use no-code tooling that don't support engineering best practices like code versioning.
dbt closes the gap by extending SQL and providing tooling around your data transformation models.
This tutorial gives an introduction to dbt with Google BigQuery and shows a basic project.


## Setup

dbt natively connects to a number of data warehousing solutions. In this tutorial, we will use BigQuery. In addition,
dbt is a Python tool, and we need to ensure it is installed and configured and that it can use our `gcloud` credentials
to run transformation queries against that BigQuery instance.

### GCP
A [project](https://console.cloud.google.com/home/dashboard?project=bolcom-dev-fffff-dbt-032) has already been 
created for this tutorial.

This project contains a [Storage bucket](https://console.cloud.google.com/storage/browser/bolcom-dev-fffff-dbt-032-raw-data;tab=objects?forceOnBucketsSortingFiltering=false&project=bolcom-dev-fffff-dbt-032&prefix=&forceOnObjectsSortingFiltering=false) 
containing our raw data. There are three CSVs with flight data from the [U.S. Department of Transportation](https://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236).
One CSV contains flight statistics and the other two map airport IDs and carrier IDs to their names. Consider this our
**E**xtract step.

These CSVs have been ingested as tables into a [BigQuery dataset](https://console.cloud.google.com/bigquery?project=bolcom-dev-fffff-dbt-032&p=bolcom-dev-fffff-dbt-032&d=landing_zone_flights&page=dataset)
named `landing_zone_flights`. Consider this our **L**oad step.

You will notice that, in addition to the `landing_zone_flights` dataset, there are also two datasets per participant, 
`flights_stg_xx` and `flights_pro_xx`, where `xx` are the initials of the participant. This will be where our
**T**ransformed data lands, and `stg` and `pro` refer to our staging and production "environments".

### Development environment

You will first set up your development environment. You will need to clone the repository, install a Python
virtual environment, configure a dbt profile and log into GCP.

The first step Clone this repository with:

```shell script
git clone git@gitlab.bol.io:platform-quality-analytics/fffff-dbt.git
```

It is assumed you have Poetry and the gcloud SDK installed on your laptop (if not, please ping us).


```shell script
poetry config virtualenvs.in-project true --local
poetry install
```

to create a virtual environment and install `dbt` into it. Next, open `profiles.yml` and replace the xes in the `_xx` in the two
lines beginning with `dataset: ...` with your initials. Then, run

```shell script
mkdir ~/.dbt
cp profiles.yml ~/.dbt/
```

to move your dbt profiles file into the location dbt expects. And finally, run

```shell script
gcloud auth login
```

and log yourself with your `bol.com` account to ensure authorization credentials are set correctly.

Everything should now be in place!

## Running our `stg` transformations

Now that the data is inplace and with your development environment configured, it is time to run our
transformations.

Run `poetry run dbt run --profile flights` to populate our data warehouse. This instructs `dbt` to compile and execute 
the data models defined in `models/`.

>Question 1: Which of the two datasets assigned to you was populated with this command? Why did dbt choose this one and
>not the other?

>Question 2: What would you need to change if your `stg` and `pro` environments were in __different GCP projects__?

## Load and test data sources

The first step of the **transformation** phase is harmonizing column names and fixing any incorrect types.
The **extract** and **load** phase were done manually via uploading the data in Cloud Storage and creating the landing zone tables in BigQuery.

Navigate to `models/base` and inspect the SQL files.
The code is fairly straightforward.
Each file contains a `SELECT` statement that loads a table and renames columns if needed. 
You will also see the first piece of dbt magic: there are [Jinja templates](https://docs.getdbt.com/docs/getting-started-with-jinja) in our SQL queries!

Statements like `{{ source('landing_zone_flights', 'flights') }}` refer to your [source tables](https://docs.getdbt.com/docs/using-sources): the BigQuery tables.
These tables are defined in `schema.yml` that [documents and tests your data models](https://docs.getdbt.com/docs/schemayml-files).

If you open `schema.yml`, you will see that `landing_zone_flights` is a source with definitions and documentation for the three BigQuery tables.
The statement `{{ source('landing_zone_flights', 'flights') }}` refers to the table `flights` within the source `landing_zone_flights`.
There is a lot more information in this file: some columns are tested for uniqueness, absence of nulls values, and relations within tables.
Tests help you make sure that your data model is not only defined, but also correct.

Navigate to `flights.sql`.
This file contains a nice trick to limit the processed data when developing.
The if-statement uses a [variable](https://docs.getdbt.com/docs/using-variables) to check the statement is run in development or in production. 
Flights data is limited to 2019-01-03 because you don't need all data during development.
This is another example of how dbt uses Jinja so to do things you normally cannot do in SQL.

The source tables are (re)created as views in BigQuery if you run `poetry run dbt run --profile flights`.
Similarly, run tests with `poetry run dbt test --profile flights`.
Try changing the names of some columns in the SQL files and see what happens if you run these commands.
(Make sure everything is back to normal before continuing!)

You have now loaded the data in the `stg` "environment" and can validate incoming data.
Try populating the `pro` environment by changing the `--target` in the `poetry run dbt run` command.
The next step is transforming the data into something interesting!

>Question 3: The `schema.yml` contains 3 types of tests: `unique`, `not_null` and `relationships`. What other
>test does dbt support out-of-the-box?

>Question 4: You can define your own macros in SQL files, in what folder should these go?

## Transform data

The sources are now defined, time to get to the part where dbt shines: transformations!
There are two transformation queries in `models/transform`.
One enriches the flight table and the other counts the number of flights per carrier.

Our transformation queries are quite similar to our load queries.
The biggest different is that now `ref()` is used to reference to data models: this is [the most important function](https://docs.getdbt.com/docs/ref) in dbt.
`enriched_flights.sql` enriches the flights table by combining the sources tables and `flights_per_carriers.sql`.
The schema definition is missing definitions and tests for `enriched_flights`, not agreeing with the [dbt coding conventions](https://github.com/fishtown-analytics/corp/blob/master/dbt_coding_conventions.md) -- my bad!

dbt also has a documentation tool to inspect your transformations.
Run the following commands to generate and serve the documentation:

```shell script
$ poetry run dbt docs generate --profile flights
$ poetry run dbt docs serve --port 8001 --profile flights
```

A new browser tab should open with documentation on the project and the resulting database.
The project overview shows the sources and models that are defined in the SQL files.
This overview gives documentation and column definitions, but also the original SQL queries and the compiled versions.
The database overview gives the same results but shows it like a database explorer.
All the way in the bottom-right corner you can find the lineage tool, giving an overview of how models or tables related
to each other. The documentation is just exported as a static HTML page, so this can be easily shared with the whole organization.

>Question 5: Could you add definitions and test for `enriched_flights`?

## Conclusion

This tutorial showed you the basics of dbt with BigQuery.
dbt supports many other databases and technologies like Presto, Microsoft SQL Server and Postgres.
Our team has [recently](https://godatadriven.com/blog/godatadriven-open-source-contribution-for-q4-2019/) extended the Spark functionality (and even our CTO has [chimed in](https://github.com/fishtown-analytics/dbt-spark/pull/43)).
Read the [dbt blog](https://blog.getdbt.com/what--exactly--is-dbt-/) for more background, check out [how The Telegraph uses it](https://medium.com/the-telegraph-engineering/dbt-a-new-way-to-handle-data-transformation-at-the-telegraph-868ce3964eb4), or go directly to the [documentation](https://docs.getdbt.com/docs/documentation)!

You can find the code and data for this tutorial [here](https://github.com/hgrif/dbt_tutorial).


## Hints

- Question 1: Check in BigQuery.
- Question 2: Compare the content of the profiles file.
- Question 3: Check the [documentation on tests](https://docs.getdbt.com/reference/resource-properties/tests).
- Question 4: Check the [documentation on tests](https://docs.getdbt.com/docs/building-a-dbt-project/jinja-macros#macros).
- Question 5: Make sure to run dbt to get your data models in BigQuery.
