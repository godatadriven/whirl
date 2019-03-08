# whirl

<img src="logo.png" width="250px" align="right" />

_Fast iterative local development and testing of Apache Airflow workflows_

The idea of _whirl_ is pretty simple: use docker containers to start up Apache Airflow and the components used in your workflow. This gives you a copy of your production environment that is running on your local machine. This allows you to run your DAG locally from start to finish - with the same code as it would on production. Being able to see your pipeline succeed gives you more confidence about the logic you are creating/refactoring and the integration between the different components you are facing. An additional benefit is that it gives (new) developers an isolated environment to experiment with your workflows.

_whirl_ connects the code of your DAG and your (mock) data to the Apache Airflow container that it spins up. By using volume mounts, you are able to make changes to your code in your favorite IDE and immediately see the effect in the running Apache Airflow UI on your machine. This even works with custom Python modules that you are developing (and using) in your DAGs.

NOTE: _whirl_ should not be a replacement for properly (unit)testing the logic you are orchestrating with Apache Airflow.


## Prerequisites

_whirl_ under the hood heavenly relies on [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/). Make sure you have it installed and that you have given enough RAM (8GB or more recommended) to Docker to let it run all your containers.

The current implementation was developed on Mac OSX, but should in theory work with any operating system supported by Docker.

## Getting Started

Clone this repository

```
git clone https://github.com/godatadriven/whirl.git <target directory of whirl>
```
For ease of use you can add the basedirectory  to your `PATH` environment variable

```
export PATH=<target directory of whirl>:${PATH}
```

## Usage

All starts with executing the _whirl_ script.

### Getting usage information
```bash
$ whirl -h
$ whirl --help
```

### Starting whirl

The default action of the script is to start the `default` environment with the dag from your current directory.

```bash
$ whirl [start] [-e <environment>]
```

Specifying the `start` commandline argument makes _whirl_ start the docker containers in daemonized mode.

If you want a more specialized environment you can add the `-e` or `--environment` commandline argument with the name of the environment. This name corresponds with a directory in the `envs` directory.


### Stopping whirl

```bash
$ whirl stop [-e <environment>]
```
Stops the `default` environment

If you want to stop all containers from a more specialized environment you can add the `-e` or `--environment` commandline argument with the name of the environment. This name corresponds with a directory in the `envs` directory.


### Use of environment variables

Inside the _whirl_ script the following environment variables are set:

| var | value | description |
| ----- | ----- | ----- |
| DOCKER\_CONTEXT\_FOLDER | ${SCRIPT_DIR}/docker | Base build context folder for docker builds referenced in docker compose |
| ENVIRONMENT\_FOLDER | ${SCRIPT_DIR}/envs/\<environment\> | Base folder for environment to start. Contains docker-compose.yml and environment specific preparation scripts |
| DAG\_FOLDER | $(pwd) | Current working directory. Used as Airflow DAG folder. Can contain preparations scripts to prepare for this specific DAG. |
| PROJECTNAME | $(basename ${DAG_FOLDER}) | |

## Structure

This project revolves around docker-compose and the notion of different environments where airflow is a central part. The rest of the environment depends on the tools/setup of the production environment used in your situation.

The +whirl_ script combines the dag and the environment to make a fully functional setup.

To accomodate different examples the environments are split up into separate environment directories inside the `envs` directory.

The second part of this project are the DAGs. To provide you with multiple examples also here a split is made into subdirectories in the `examples` directory.

### Environments

Environments basically use docker compose to startup dependent docker images which together mimick your production environment. Basis of the envrionment is the docker-compose.yml which in it's minimal form contains the airflow container to startup.
Extra tools like for example `s3`, `sftp` etc. can be linked together in the docker-compose file to form your specific environment.

Each environment also contains some setup code needed for airflow to understand the environment. Think off `Connections` adn `Variables` for example. For this each environment contains a `whirl.setup.d` directory which is mounted in the Airflow container. On startup all scripts in this directory are executed.
This is the place to install and configure extra client libraries that are needed to make the environment function correctly (for example awscli for s3 access).

### Dags

The dags are situated in this project inside the `examples` directory. In your real world project you can have your code inside your own project of course (outside the example directory and outside this project)

Each example directory consists of at least an example DAG. Also project specific code can be made available there. Same as with the environment the DAG directory can contain a `whirl.setup.d` directory which is also mounted in the Airflow container. On startup all scripts in this directory are executed.
This is also the place to install and configure extra client libraries that are needed to make the dag function correctly (for example adding a mock api endpoint).


## Examples

This repository comes with a couple of example environments and workflows to demonstrate the use of _whirl_. The components used in the example workflows might be of help in kickstarting the creation of your own environment. If you have a good addition to the environments section, feel free to submit a merge request!

### Default

The default (example) environment only involves one component, namely the Apache Airflow docker container itself. The environment contains one preparation script called `01_enable_local_ssh.sh`. As the name suggests, this will make SSH to localhost in that container possible. We also add a new connection called `ssh_local` to the Airflow connections.

To run our DAG, perform the following (assuming you have put _whirl_ to your `PATH`)

```bash
$ cd ./examples/localhost-ssh-example
$ whirl
```

Open your browser to http://localhost:5000 to see the Airflow UI appear. Manually enable the DAG and see the pipeline get marked success.

### api-to-s3

### SFTPOperator + PythonOperator + MySQL example

In this example we have created an environment that spins up an SFTP Server and a MySQL instance in separate containers, together with the Airflow one. The environment contains two startup scripts in the `whirl.setup.d` folder: `01_prepare_sftp.sh` which adds an SFTP connection to Airflow and `02_prepare_mysql.sh` which adds a MySQL connection to Airflow.

To run the corresponding example DAG, perform the following (assuming you have put _whirl_ to your `PATH`)

```bash
$ cd ./examples/sftp-mysql-example
$ MOCK_DATA_FOLDER=$(pwd)/mock-data
$ whirl -e sftp-mysql-example
```

Open your browser to http://localhost:5000 to see the Airflow UI appear. Manually enable the DAG and see the pipeline get marked success.

In this example we set an extra environment variable `MOCK_DATA_FOLDER` that will be mounted to our Airflow container. Next to that, in the example folder we have a `whirl.setup.d` as well, which contains the script `01_cp_mock_data_to_sftp.sh`. This script gets executed in the container as well and will do a couple of things:

- it will rename the file `mocked-data-#ds_nodash#.csv` that is in the `./mock-data` folder. It will replace `#ds_nodash#` with the same value that Apache Airflow will give when templating `ds_nodash` in the Python files. This means we have a file available for our specific DAG run. The logic to rename these files is provide by the Apache Airflow container we build. it is located in the `/etc/airflow/functions/date_replacement.sh` in the container.
- It will copy this file to the SFTP server. Because that is what our DAG expects. When it starts it will try to obtain that file from the SFTP server to the local filesystem.


## References

An early version of _whirl_ was brought to live at [ING](https://github.com/ing-bank). Bas Beelen gave a presentation about how _whirl_ was helpful in their infrastructure during the 2nd Apache Airflow Meetup, January 23 2019, hosted at Google London HQ.

[![Whirl explained at Apache Airflow Meetup](./whirl-youtube.png)](https://www.youtube.com/watch?v=jqK_HCOJ9Ak)
