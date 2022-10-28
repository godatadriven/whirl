#### Testing failure email

In this example the dag is set to fail. This example is all about how to configure airflow to use a external smtp server for sending the failure emails.
We have created an environment that spins up an smtp server together with the Airflow one.


To run the corresponding example DAG, perform the following (assuming you have put _whirl_ to your `PATH`)

```bash
$ cd ./examples/external-smtp-for-failure-emails
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to see the Airflow UI appear. Manually enable the DAG and see the pipeline get marked failed.
Also open your browser at [http://localhost:1080](http://localhost:1080) for the email client where the emails should show up.

The environment to be used is set in the `.whirl.env` in the DAG directory. In the environment folder there is also a `.whirl.env` which specifies specific Airflow configuration variables.
