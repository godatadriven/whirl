#### Remote logging for Airflow

In this example the dag is not the most important part. This example is all about how to configure airflow to log to S3.

The environment to be used (`airflow-s3-logging`) is set in the `.whirl.env` in the DAG directory. In the environment folder there is also a `.whirl.env` which specifies S3 specific variables.

The docker compose of the environment that spins up an S3 server together with the Airflow one. The environment contains a setup script in the `whirl.setup.d` folder:

- `01_add_connection_s3.sh` which:
    -  adds an S3 connection to Airflow
    -  Installs awscli Python libraries and configures them to connect to the S3 server
    -  Creates a bucket (with adding a `/etc/hosts` entry to support the [virtual host style method](https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html))
- `02_configue_logging_to_s3.sh` which:
    -  exports environment varibles which airflow uses to override the default config. For example: `export AIRFLOW__CORE__REMOTE_LOGGING=True`


To run the corresponding example DAG, perform the following (assuming you have put _whirl_ to your `PATH`)

```bash
$ cd ./examples/logging-to-s3
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to see the Airflow UI appear. Manually enable the DAG and see the pipeline get marked success. If you open one of the logs, the first line shows that the log is retrieved from S3.



