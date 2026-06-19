#### Custom Timetable Example

In this example we demonstrate a custom [Airflow
timetable](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/timetable.html).
Timetables let you express scheduling logic that cannot be captured by a cron
expression or a fixed interval.

The timetable in this example (`FullMoonTimetable`) schedules a DAG run on every
full moon. It uses the [`ephem`](https://pypi.org/project/ephem/) astronomy
library to compute the previous/next full moon dates and is shipped as an
[Airflow plugin](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/plugins.html)
(`FullMoonTimetablePlugin`).

The DAG (`example_timetable`) uses `schedule=FullMoonTimetable()` and runs a
single `BashOperator` that echoes the data interval of each run.

The default environment (`just-airflow`) only contains the core Airflow
component.

The custom plugin lives under `whirl.setup.d/plugins/` and the environment
contains a setup script in the `whirl.setup.d/` folder:

 - `01_install_custom_timetable.sh` which `pip install`s the plugin package
   (including its `ephem` dependency) so the timetable is registered with
   Airflow.

To run this example:

```bash
$ cd ./examples/airflow-timetable
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access
the Airflow UI. The DAG's next run will be scheduled for the upcoming full moon.