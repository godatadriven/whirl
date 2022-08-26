#### Rest API to S3 Storage Example

In this example we are going to:

1. Consume a REST API;
2. Convert the JSON data to Parquet;
3. Store the result in a S3 bucket.

The default environment (`api-python-s3`) includes containers for:

 - A S3 server;
 - A MockServer instance
 - The core Airflow component.
 
The environment contains a setup script in the `whirl.setup.d/` folder:

 - `01_add_connection_api.sh` which:

   -  Adds a S3 connection to Airflow;
   -  Installs the `awscli` Python libraries and configures them to connect to the S3 server;
   -  Creates a bucket (with a `/etc/hosts` entry to support the [virtual host style method](https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html)).

It is also possible to use a more complex environment (`api-python-s3-k8s`) that adds a Kubernetes cluster and the use of Airflows KubernetesExecutor to run this example. This environment is explained in depth in the [environment README](../../envs/api-python-s3-k8s/README.md)

To run this example with the default environment:

```bash
$ cd ./examples/api-to-s3
$ whirl
```

To run this example with the k8s based environment:

```bash
$ cd ./examples/api-to-s3
$ whirl -e api-python-s3-k8s
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access the Airflow UI. Manually enable the DAG and watch the pipeline run to successful completion.

This example includes a `.whirl.env` configuration file in the DAG directory. In the environment folder there is also a `.whirl.env` which specifies S3-specific variables. The example folder also contains a `whirl.setup.d/` directory which contains an initialization script (`01_add_connection_api_and_mockdata.sh`). This script is executed in the container after the environment-specific scripts have run and will:

 - Add a connection to the API endpoint;
 - Add an [expectation](http://www.mock-server.com/mock_server/creating_expectations.html) for the MockServer to know which response needs to be sent for which requested path;
 - Install Pandas and PyArrow to support transforming the JSON into a Parquet file;
 - Create a local directory where the intermediate file is stored before being uploaded to S3.

The DAG contains 2 tasks which both use the PythonOperator to:
- call the mock api to retrieve the JSON data and convert it to a local parquet file
- use the S3Hook to copy the local file to the S3 bucket