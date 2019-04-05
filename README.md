# whirl

<img src="logo.png" width="250px" align="right" />

_Fast iterative local development and testing of Apache Airflow workflows._

The idea of _whirl_ is pretty simple: use Docker containers to start up Apache Airflow and the other components used in your workflow. This gives you a copy of your production environment that runs on your local machine. You can run your DAG locally from start to finish - with the same code as in production. Seeing your pipeline succeed gives you more confidence about the logic you are creating/refactoring and how it integrates with other components. It also gives new developers an isolated environment for experimenting with your workflows.

_whirl_ connects the code of your DAG and your (mock) data to the Apache Airflow container that it spins up. Using volume mounts you are able to make changes to your code in your favorite IDE and immediately see the effect in the running Apache Airflow UI on your machine. This also works with custom Python modules that you are developing and using in your DAGs.

NOTE: _whirl_ is not intended to replace proper (unit) testing of the logic you are orchestrating with Apache Airflow.


## Prerequisites

_whirl_ relies on [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/). Make sure you have it installed. If using _Docker for Mac_ or _Windows_ ensure that you have configured it with sufficient RAM (8GB or more recommended) for running all your containers.

When you want to use _whirl_ in your CI pipeline (currently work in progress), you need to have `jq` installed. For example, with Homebrew:

```bash
brew install jq
```

The current implementation was developed on macOS but it intended to work with any platform supported by Docker.

## Getting Started

Clone this repository:

```
git clone https://github.com/godatadriven/whirl.git <target directory of whirl>
```
For ease of use you can add the base directory  to your `PATH` environment variable

```
export PATH=<target directory of whirl>:${PATH}
```

## Usage

The `whirl` script is used to perform all actions.

#### Getting usage information

```bash
$ whirl -h
$ whirl --help
```

#### Starting whirl

The default action is to start the DAG in your current directory. It expects an environment to be configured. You can pass this as a command line argument or you can configure it in a `.whirl.env` file. (See #Configuring environment variables.) The environment refers to a directory with the same name in the `envs` directory located near the _whirl_ script.

```bash
$ whirl [start] [-e <environment>]
```

Specifying the `start` command line argument is a more explicit way to start _whirl_.

#### Stopping whirl

```bash
$ whirl stop [-e <environment>]
```
Stops the configured environment.

If you want to stop all containers from a specific environment you can add the `-e` or `--environment` commandline argument with the name of the environment. This name corresponds with a directory in the `envs` directory.

#### Usage in a CI Pipeline _(work in progress)_

We do not currently have a complete example of how to usage _whirl_ as part of a CI pipeline. However the first step in doing this is involves starting while in `ci` mode. This will:
 
  - run the Docker containers daemonized in the background;
  - ensure the DAG(s) are unpaused; and
  - wait for the pipeline to either succeed or fail.
  
Upon success the containers will be stopped and exit successfully.

At present we don't exit upon failure because it can be useful to be able to inspect the environment to see what happened. In the future we plan to print out the logs of the failed task and cleanup before indicating the pipeline has failed.

#### Configuring Environment Variables

Instead of using the environment option each time you run _whirl_, you can also configure your environment in a `.whirl.env` file. This can be in four places:

- In your home directory, at `~/.whirl.env`. You can configure a default environment that will be used for every DAG.
- In the root directory of this repository. This can also specify a default environment to be used when starting _whirl_. (This repository already containers an example file that you can modify.)
- In your `env/` directory. The environment directory to use can be set by any of the other `.whirl.env` files or specified on the commandline. This can be handy for environment specific variables.
- In your DAG directory to override the default environment to be used for that specific DAG.

For example, you can set the `PYTHON_VERSION` that you want to be used. The default `PYTHON_VERSION` used is 3.6.

#### Use of environment variables

Inside the _whirl_ script the following environment variables are set:

| Environment Variable | Value | Description |
| ----- | ----- | ----- |
| `DOCKER_CONTEXT_FOLDER` | `${SCRIPT_DIR}/docker` | Base build context folder for Docker builds referenced in Docker Compose |
| `ENVIRONMENT_FOLDER` | `${SCRIPT_DIR}/envs/<environment>` | Base folder for environment to start. Contains `docker-compose.yml` and environment specific preparation scripts. |
| `DAG_FOLDER` | `$(pwd)` | Current working directory. Used as Airflow DAG folder. Can contain preparation scripts to prepare for this specific DAG. |
| `PROJECTNAME` | `$(basename ${DAG_FOLDER})` | |

## Structure

This project is based on docker-compose and the notion of different environments where Airflow is a central part. The rest of the environment depends on the tools/setup of the production environment used in your situation.

The _whirl_ script combines the DAG and the environment to make a fully functional setup.

To accommodate different examples:

 - The environments are split up into separate environment-specific directories inside the `envs/` directory.
 - The DAGS are split into sub-directories in the `examples/` directory.

#### Environments

Environments use Docker Compose to start containers which together mimic your production environment. The basis of the environment is the `docker-compose.yml` file which as a minimum declares the Airflow container to run. Extra tools (e.g. `s3`, `sftp`) can be linked together in the docker-compose file to form your specific environment.

Each environment also contains some setup code needed for Airflow to understand the environment, for example `Connections` and `Variables`. Each environment has a `whirl.setup.d/` directory which is mounted in the Airflow container. On startup all scripts in this directory are executed. This is a location for installing and configuring extra client libraries that are needed to make the environment function correctly; for example `awscli` if S3 access is required.

#### DAGs

The DAGs in this project are inside the `examples/` directory. In your own project you can have your code in its own location outside this repository.

Each example directory consists of at least one example DAG. Also project- specific code can be placed there. As with the environment the DAG directory can contain a `whirl.setup.d/` directory which is also mounted inside the Airflow container. Upon startup all scripts in this directory are executed. The environment-specific `whirl.setup.d/` is executed first, followed by the DAG one.

This is also a location for installing and configuring extra client libraries that are needed to make the DAG function correctly; for example a mock API endpoint.

## Examples

This repository contains some example environments and workflows. The components used in the example workflows might serve as a starting point for your own environment. If you have a good example you'd like to add, please submit a merge request!

#### SSH to Localhost

The first example environment only involves one component, namely the Apache Airflow docker container itself. The environment contains one preparation script called `01_enable_local_ssh.sh`. As the name suggests, this will make SSH to localhost in that container possible. We also add a new connection called `ssh_local` to the Airflow connections.

To run our DAG, perform the following (assuming you have put _whirl_ to your `PATH`)

```bash
$ cd ./examples/localhost-ssh-example
$ whirl -e local-ssh
```

Open your browser to http://localhost:5000 to see the Airflow UI appear. Manually enable the DAG and see the pipeline get marked success.

#### Rest API to S3 storage example

In this example we are going to consume a rest api and convert the JSON data to Parquet and store it in an S3 bucket.
We have created an environment that spins up an S3 server and a MockServer instance in separate containers, together with the Airflow one. The environment contains a setup script in the `whirl.setup.d` folder:

- `01_add_connection_api.sh` which:
	-  adds an S3 connection to Airflow
	-  Installs awscli Python libraries and configures them to connect to the S3 server
	-  Creates a bucket (with adding a `/etc/hosts` entry to support the [virtual host style method](https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html))


To run the corresponding example DAG, perform the following (assuming you have put _whirl_ to your `PATH`)

```bash
$ cd ./examples/api-python-s3
$ whirl
```

Open your browser to http://localhost:5000 to see the Airflow UI appear. Manually enable the DAG and see the pipeline get marked success.

The environment to be used is set in the `.whirl.env` in the DAG directory. In the environment folder there is also a `.whirl.env` which specifies S3 specific variables. Next to that, in the example folder we have a `whirl.setup.d` as well, which contains the script `01_add_connection_api_and_mockdata.sh`. This script gets executed in the container after the environment specific scripts have run and will do a couple of things:

- Add a connection to the API endpoint
- Add a [expectation](http://www.mock-server.com/mock_server/creating_expectations.html) for the mockserver to know which response needs to be send for which path that is requested
- Install Pandas and PyArrow to support transforming the JSON into a Parquet file in the first task
- Create a local directory where the intermediate file is stored before it is sent to S3 in the second task


#### SFTPOperator + PythonOperator + MySQL example

In this example we have created an environment that spins up a SFTP Server and a MySQL instance in separate containers, together with the Airflow one. The environment contains two startup scripts in the `whirl.setup.d` folder:

- `01_prepare_sftp.sh` which adds a SFTP connection to Airflow
- `02_prepare_mysql.sh` which adds a MySQL connection to Airflow

To run the corresponding example DAG, perform the following (assuming you have put _whirl_ to your `PATH`)

```bash
$ cd ./examples/sftp-mysql-example
$ whirl
```

Open your browser to http://localhost:5000 to see the Airflow UI appear. Manually enable the DAG and see the pipeline get marked success.

The environment to be used is set in the `.whirl.env` in the DAG directory. In the environment folder there is also a `.whirl.env` which specifies that the `MOCK_DATA_FOLDER` is set. Next to that, in the example folder we have a `whirl.setup.d` as well, which contains the script `01_cp_mock_data_to_sftp.sh`. This script gets executed in the container after the environment specific scripts have run and will do a couple of things:

- it will rename the file `mocked-data-#ds_nodash#.csv` that is in the `./mock-data` folder. It will replace `#ds_nodash#` with the same value that Apache Airflow will give when templating `ds_nodash` in the Python files. This means we have a file available for our specific DAG run. The logic to rename these files is located in `/etc/airflow/functions/date_replacement.sh` in the Airflow container.
- It will copy this file to the SFTP server, because that is what our DAG expects. When it starts it will try to obtain that file from the SFTP server to the local filesystem.


## References

An early version of _whirl_ was brought to live at [ING](https://github.com/ing-bank). Bas Beelen gave a presentation about how _whirl_ was helpful in their infrastructure during the 2nd Apache Airflow Meetup, January 23 2019, hosted at Google London HQ.

[![Whirl explained at Apache Airflow Meetup](./whirl-youtube.png)](https://www.youtube.com/watch?v=jqK_HCOJ9Ak)
