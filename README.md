# whirl
Fast iterative local development and testing of Apache Airflow workflows

The idea of _whirl_ is pretty simple: start up Airflow and the components used in your workflow in docker containers. This gives you a copy of your production environment that's running on your local machine. This allows you to run your DAG locally from start to finish - with the same code as it would on production. By seeing a green pipeline you can be more confident that the logic you have in place is sound.

_whirl_ connects the code of the DAG you are working on, the mock-data you want to use and (in case you have them) and the custom Python module(s) you are developing to the Airflow containers. Any changes you make to your code

By mounting your DAG code, mock-data and custom modules to the container, you get to see your code changes immediately on your screen.

<img src="logo.png" align="right" />

## Prerequisites

(docker + docker-compose). Enough RAM to run multiple docker ocntainers etc.

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
```
$ whirl -h
$ whirl --help
```

### Starting whirl

The default action of the script is to start the `default` environment with the dag from your current directory. 

Specifying the `start` commandline argument makes whirl start the docker containers in daemonized mode. 

```
$ whirl
$ whirl start
```
If you want a more specialized environment you can add the `-e` or `--environment` commandline argument with the name of the environment. This name corresponds with a directory in the `envs` directory.

```
$ whirl -e <envronment>
$ whirl start -e <envronment>
```

### Stopping whirl

```
$ whirl stop
```
Stops the `default` environment

If you want to stop all containers from a more specialized environment you can add the `-e` or `--environment` commandline argument with the name of the environment. This name corresponds with a directory in the `envs` directory.

```
$ whirl stop -e <environment>
```

### Use of environment variables

Inside the whirl script the following environment variables are set:

| var | value | description |
| ----- | ----- | ----- |
| DOCKER\_CONTEXT\_FOLDER | ${SCRIPT_DIR}/docker | Base build context folder for docker builds referenced in docker compose |
| ENVIRONMENT\_FOLDER | ${SCRIPT_DIR}/envs/\<environment\> | Base folder for environment to start. Contains docker-compose.yml and environment specific preparation scripts |
| DAG\_FOLDER | $(pwd) | Current working directory. Used as Airflow DAG folder. Can contain preparations scripts to prepare for this specific DAG. |
| PROJECTNAME | $(basename ${DAG_FOLDER}) | |

## Structure

- envs. = docker-compose + preparations
- whirl: combines DAG files with environment
- dag preparations


## Examples

### default (localhost ssh)

### api-to-s3

### sftp-mysql
