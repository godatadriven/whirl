#### SSH to Localhost

The directory `example/localhost-ssh-example/` contains  the Airflow DAG and the environment to be used is configured inside the `.whirl.env` file. (it uses the `local-ssh` environment)

The local-ssh environment only involves one component, the Apache Airflow docker container itself. The environment contains one preparation script called `01_enable_local_ssh.sh` which makes it possible in that container to SSH to `localhost`. The script also adds a new connection called `ssh_local` to the Airflow connections.

The DAG has 1 task that simply uses the SSHOperator to copy a file. A succesfull run proves that we are able to use a airflow connection to execute commands through an ssh connection.

To run this example:

```bash
$ cd ./examples/localhost-ssh-example
# Note: here we pass the whirl environment 'local-ssh' as a command-line argument.
$ whirl -e local-ssh
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access the Airflow UI. Manually enable the DAG and watch the pipeline run to successful completion.

