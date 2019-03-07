# whirl
Fast iterative local development and testing of Apache Airflow workflows

The idea of _whirl_ is pretty simple: start up Airflow and the components used in your workflow in docker containers. This gives you a copy of your production environment that's running on your local machine. This allows you to run your DAG locally from start to finish - with the same code as it would on production. By seeing a green pipeline you can be more confident that the logic you have in place is sound.

_whirl_ connects the code of the DAG you are working on, the mock-data you want to use and (in case you have them) and the custom Python module(s) you are developing to the Airflow containers. Any changes you make to your code

By mounting your DAG code, mock-data and custom modules to the container, you get to see your code changes immediately on your screen.

<img src="logo.png" align="right" />

## Prerequisites

(docker + docker-compose). Enough RAM to run multiple docker ocntainers etc.

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
