# whirl

<img src="logo.png" width="250px" align="right" />

_Fast iterative local development and testing of Apache Airflow workflows_

The idea of _whirl_ is pretty simple: use docker containers to start up Apache Airflow and the components used in your workflow. This gives you a copy of your production environment that is running on your local machine. This allows you to run your DAG locally from start to finish - with the same code as it would on production. Being able to see your pipeline succeed gives you more confidence about the logic you are creating/refactoring and the integration between the different components you are facing. An additional benefit is that it gives (new) developers an isolated environment to experiment with your workflows.

_whirl_ connects the code of your DAG and your (mock) data to the Apache Airflow container that it spins up. By using volume mounts, you are able to make changes to your code in your favorite IDE and immediately see the effect in the running Apache Airflow UI on your machine. This even works with custom Python modules that you are developing (and using) in your DAGs.

NOTE: _whirl_ should not be a replacement for properly (unit)testing the logic you are orchestrating with Apache Airflow.


## Prerequisites

_whirl_ under the hood heavenly relies on [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/). Make sure you have it installed and that you have given enough RAM (8GB or more recommended) to Docker to let it run all your containers.

The current implementation was developed on Mac OSX, but should in theory work with any operating system supported by Docker.

## Usage

- whirl start, stop, daemon etc.


## Structure

- envs. = docker-compose + preparations
- whirl: combines DAG files with environment
- dag preparations


## Examples

### default (localhost ssh)

### api-to-s3

### sftp-mysql


