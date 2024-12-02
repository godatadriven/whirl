# Spark OpenTelemetry

This example demos reporting Traces from Airflow and its child Spark jobs to a
tracing backend using OpenTelemetry.

## Usage

This example relies on the Spot package: [github/godatadriven/spot][spot]. This
must be installed before use:

1. Clone the spot project
2. Build the spot-complete jar file
3. Copy the compatible version (Spark 3.4, Scala 2.12) into the `whirl.setup.d/` dir
4. Run whirl
5. Access the UIs in a browser:
    - Airflow UI: [localhost:5000](http://localhost:5000/) (admin/admin)
    - Grafana UI: [localhost:3000](http://localhost:3000/)

```shell
cd spot
sbt +assembly
cd ../whirl/examples/spark-opentelemetry
cp ../../../spot/spot-complete/target/spark-3.5-jvm-2.12/spot-complete-*.jar ./whirl.setup.d/spot-complete.jar`
../../whirl
```

[spot]: https://github.com/godatadriven/spot/