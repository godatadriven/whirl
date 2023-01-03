# whirl

<img src="logo.png" width="250px" align="right" />

_Fast iterative local development and testing of Apache Airflow workflows._

The idea of _whirl_ is pretty simple: use Docker containers to start up Apache Airflow and the other components used in your workflow. This gives you a copy of your production environment that runs on your local machine. You can run your DAG locally from start to finish - with the same code as in production. Seeing your pipeline succeed gives you more confidence about the logic you are creating/refactoring and how it integrates with other components. It also gives new developers an isolated environment for experimenting with your workflows.

_whirl_ connects the code of your DAG and your (mock) data to the Apache Airflow container that it spins up. Using volume mounts you are able to make changes to your code in your favorite IDE and immediately see the effect in the running Apache Airflow UI on your machine. This also works with custom Python modules that you are developing and using in your DAGs.

NOTE: _whirl_ is not intended to replace proper (unit) testing of the logic you are orchestrating with Apache Airflow.


## Prerequisites

_whirl_ relies on [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/). Make sure you have it installed. If using _Docker for Mac_ or _Windows_ ensure that you have configured it with sufficient RAM (8GB or more recommended) for running all your containers.

When you want to use _whirl_ in your CI pipeline, you need to have `jq` installed. For example, with Homebrew:

```bash
brew install jq
```

The current implementation was developed on macOS but is intended to work with any platform supported by Docker. In our experience, Linux and macOS are fine. You can run it on native Windows 10 using [WSL](https://docs.microsoft.com/en-us/windows/wsl/about). Unfortunately, Docker on Windows 10 (version 1809) is hamstrung because it relies on Windows File Sharing (CIFS) to establish the volume mounts. Airflow hammers the volume a little harder than CIFS can handle, and you'll see intermittent FileNotFound errors in the volume mount. This may improve in the future. For now, running _whirl_ inside a Linux VM in Hyper-V gives more reliable results.

### Airflow Versions
As of January 2021, Whirl uses Airflow 2.x.x as the default version. A specific tag was made for Airflow 1.10.x, which can be found [here](https://github.com/godatadriven/whirl/tree/airflow-1.10.x)

## Getting Started

### Development

Clone this repository:

```
git clone https://github.com/godatadriven/whirl.git <target directory of whirl>
```
For ease of use you can add the base directory to your `PATH` environment variable, so the command `whirl` is available.
```
export PATH=<target directory of whirl>:${PATH}
```

### Use the release

Download the [latest Whirl release artifact](https://github.com/godatadriven/whirl/releases/latest/download/whirl-release.tar.gz)

Extract the file (for example into `/usr/local/opt`)

```bash
tar -xvzf whirl-release.tar.gz -C /usr/local/opt
```

Make sure the whirl script is available on your path
```bash
export PATH=/usr/local/opt/whirl:$PATH
```

## Usage

The `whirl` script is used to perform all actions.

#### Getting usage information

```bash
$ whirl -h
$ whirl --help
```

#### Starting whirl

The default action is to start the DAG in your current directory.

With the `[-x example]` commandline argument you can run whirl from anywhere and tell whirl which example dag to run. The example refers to a directory with the same name in the `examples` directory located near the _whirl_ script.

Whirl expects an environment to be configured. You can pass this as a command line argument `[-e environment]` or you can configure it as environment variable `WHIRL_ENVIRONMENT` in a `.whirl.env` file. (See [Configuring environment variables](#configuring-environment-variables).) The environment refers to a directory with the same name in the `envs` directory located near the _whirl_ script.

```bash
$ whirl [-x example] [-e <environment>] [start]
```

Specifying the `start` command line argument is a more explicit way to start _whirl_.

#### Stopping whirl

```bash
$ whirl  [-x example] [-e <environment>] stop
```
Stops the configured environment.

If you want to stop all containers from a specific environment you can add the `-e` or `--environment` commandline argument with the name of the environment. This name corresponds with a directory in the `envs` directory.

#### Usage in a CI Pipeline

We run most of the examples from within our own CI (github actions, see for implementation details our [github workflow](.github/workflows/whirl-ci.yml).

You are able to run an example in `ci` mode on your local system by useing the `whirl ci` command. This will:
 
  - run the Docker containers daemonized in the background;
  - ensure the DAG(s) are unpaused; and
  - wait for the pipeline to either succeed or fail.
  
Upon success the containers will be stopped and exit successfully.

In case of failure (or success if failure is expected)we print out the logs of the failed task and cleanup before indicating the pipeline has failed.

#### Configuring Environment Variables

Instead of using the environment option each time you run _whirl_, you can also configure your environment in a `.whirl.env` file. This can be in three places. They are applied in order:

- A `.whirl.env` file in the root of this repository. This can also specify a default environment to be used when starting _whirl_. You do this by setting the `WHIRL_ENVIRONMENT` which references a directory in the [`envs`](./envs) folder. This repository contains an example you can modify. It specifies the default `PYTHON_VERSION` to be used in any environment.
- A `.whirl.env` file in your [`envs/{your-env}`](./envs) subdirectory. The environment directory to use can be set by any of the other `.whirl.env` files or specified on the commandline. This is helpful to set environment specific variables. Of course it doesn't make much sense to set the `WHIRL_ENVIRONMENT` here.
- A `.whirl.env` in your DAG directory to override any environment variables. This can be useful for example to overwrite the (default) `WHIRL_ENVIRONMENT`.

#### Internal environment variables

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

This repository contains some example environments and workflows. The components used might serve as a starting point for your own environment. If you have a good example you'd like to add, please submit a merge request!

Each example contains it's own README file to explain the specifics of that example.

#### Generic running of examples

To run a example:

```bash
$ cd ./examples/<example-dag-directory>
# Note: here we pass the whirl environment as a command-line argument. It can also be configured with the WHIRL_ENVIRONMENT variable
$ whirl -e <environment to use>
```

or
```bash
$
# Note: here we pass the whirl environment as a command-line argument. It can also be configured with the WHIRL_ENVIRONMENT variable
$ whirl -x <example to run> -e <environment to use>
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access the Airflow UI. Manually enable the DAG and watch the pipeline run to successful completion.


## References

An early version of _whirl_ was brought to life at [ING](https://github.com/ing-bank). Bas Beelen gave a presentation describing how _whirl_ was helpful in their infrastructure during the 2nd Apache Airflow Meetup, January 23 2019, hosted at Google London HQ.

[![Whirl explained at Apache Airflow Meetup](./whirl-youtube.png)](https://www.youtube.com/watch?v=jqK_HCOJ9Ak)
