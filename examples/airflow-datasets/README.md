#### Dataset Aware Scheduling Example

In this example we are going to have multiple dags which depend on each other through the dataset aware scheduling.

The default environment (`api-s3-dataset`) includes containers for:

 - A S3 server;
 - A MockServer instance
 - The core Airflow components (webserver, scheduler, triggerer).
 - The airflow database (postgres)
 
The environment contains a setup script in the `whirl.setup.d/` folder:

 - `01_add_connection_api.sh` which:

   -  Adds a S3 connection to Airflow;
   -  Installs the `awscli` Python libraries and configures them to connect to the S3 server;
   -  Creates a bucket (with a `/etc/hosts` entry to support the [virtual host style method](https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html)).

To run this example with the default environment:

```bash
$ cd ./examples/airflow-datasets
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access the Airflow UI. Manually enable the DAG and watch the pipeline run to successful completion.

This example includes a `.whirl.env` configuration file in the DAG directory. In the environment folder there is also a `.whirl.env` which specifies S3-specific variables. The example folder also contains a `whirl.setup.d/` directory which contains an initialization script (`01_add_connection_api_and_mockdata.sh`). This script is executed in the airflow containers after the environment-specific scripts have run and will:

 - Add a connection to the API endpoint;
 - Add an [expectation](http://www.mock-server.com/mock_server/creating_expectations.html) for the MockServer to know which response needs to be sent for which requested path;
 - Install Pandas and PyArrow to support transforming the JSON into a Parquet file;
 - Create a local directory where the intermediate file is stored before being uploaded to S3.

For the DAGs we wanted to test different scenarios

##### Simple single dataset dependency


