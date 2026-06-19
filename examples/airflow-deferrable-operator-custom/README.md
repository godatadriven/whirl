#### Custom Deferrable Operator Example

In this example we demonstrate how to build your **own** [deferrable
sensor](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/deferring.html)
together with a custom `Trigger`, rather than using a built-in one (for the
built-in variant see the
[airflow-deferrable-operator](../airflow-deferrable-operator) example).

The custom code lives under `src/custom/` and is packaged with the included
`setup.py`:

 - `operators/api_check_operator.py` — `WaitForStartedStatusSensor`, a sensor
   whose `execute` immediately `self.defer(...)`s onto a custom trigger and
   resumes in `execute_complete` once the trigger fires.
 - `triggers/api_check_trigger.py` — `ApiCheckTrigger`, an async trigger that
   polls a REST API every second (using `aiohttp`) until the API returns a
   given status, then emits a single `TriggerEvent`.

The DAG (`example_custom_sensor_async`) waits for the API to report status
`Started` and then runs a downstream `EmptyOperator`.

This example uses the `airflow-with-mockserver` environment, which adds a
[MockServer](https://www.mock-server.com/) instance next to the core Airflow
component.

The environment contains a setup script in the `whirl.setup.d/` folder:

 - `01_add_connection_api_and_mockdata.sh` which:

   - Registers two MockServer expectations for `/testapi`: it returns
     `{"status": "Pending"}` for the first 30 calls and `{"status": "Started"}`
     afterwards, so the trigger has to poll for a while before completing;
   - Installs the custom Python package (and `aiohttp`) so the operator and
     trigger are importable by both the worker and the triggerer.

> **Note:** deferrable operators require Airflow 2.3.0 or higher. This is
> enforced through `MINIMAL_AIRFLOW_VERSION=2.3.0` in the example `.whirl.env`.

To run this example:

```bash
$ cd ./examples/airflow-deferrable-operator-custom
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access
the Airflow UI. Trigger the DAG and watch the `wait` task enter the `deferred`
state while the trigger polls MockServer, then complete once the status flips to
`Started`.