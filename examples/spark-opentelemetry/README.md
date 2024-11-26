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

```shell
cd spot
sbt +assembly
cd ../whirl/examples/spark-opentelemetry
cp ../../../spot/spot-complete/target/spark-3.4-jvm-2.12/spot-complete-3.4_2.12*.jar ./whirl.setup.d`
../../whirl
```

[spot]: https://github.com/godatadriven/spot/