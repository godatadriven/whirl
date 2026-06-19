#### Deferrable Operator Example

In this example we demonstrate Airflow [deferrable
operators](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/deferring.html).
A deferrable operator (or sensor) can suspend itself and hand its waiting work
over to the Airflow *triggerer*, freeing up the worker slot while it waits.
This makes long waits (for a time window, a file, an external job, ...) much
cheaper in terms of resources.

The DAG (`example_time_delta_sensor_async`) uses the built-in
`TimeDeltaSensorAsync`, a drop-in replacement for `TimeDeltaSensor` that defers
instead of blocking a worker. It waits 120 seconds and then runs a downstream
`EmptyOperator`.

The default environment (`just-airflow`) only contains the core Airflow
component (which includes the triggerer needed to run deferrable tasks).

> **Note:** deferrable operators require Airflow 2.3.0 or higher. This is
> enforced through `MINIMAL_AIRFLOW_VERSION=2.3.0` in the example `.whirl.env`.

To run this example:

```bash
$ cd ./examples/airflow-deferrable-operator
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access
the Airflow UI. Manually trigger the DAG and watch the `wait` task enter the
`deferred` state before completing.

For a custom implementation of a deferrable sensor (with its own Trigger), see
the [airflow-deferrable-operator-custom](../airflow-deferrable-operator-custom)
example.