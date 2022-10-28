#### Having an external database for Airflow

In this example the dag is not the most important part. This example is all about how to configure airflow to use a external database.
We have created an environment (`external-airflow-db`) that spins up an postgres database server together with the Airflow one.


To run the corresponding example DAG, perform the following (assuming you have put _whirl_ to your `PATH`)

```bash
$ cd ./examples/external-airflow-db
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to see the Airflow UI appear. Manually enable the DAG and see the pipeline get marked success.

The environment to be used is set in the `.whirl.env` in the DAG directory. In the environment folder there is also a `.whirl.env` which specifies Postgres specific variables.


