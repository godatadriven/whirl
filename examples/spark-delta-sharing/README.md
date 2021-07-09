# Delta sharing experiment

## Preparation

We need the docker container for delta server. It can be build from the [github repo](git@github.com:delta-io/delta-sharing.git) with the command `build.sbt docker:publishLocal` for now. It might become available on docker-hub

## First experiments without airflow

`docker exec -ti s3-spark-delta-sharing_airflow_1 /bin/bash`

We use the airflow docker container (which contains pyspark) to execute the following commands:

### (Inside the s3-spark-delta-sharing_airflow_1 container) Save a local sharing profile file 

```bash
echo '{
  "shareCredentialsVersion": 1,
  "endpoint": "http://delta:8080/delta-sharing/",
  "bearerToken": "authTokenDeltaSharing432"
}' > /opt/airflow/delta.profile
```

### (Inside the s3-spark-delta-sharing_airflow_1 container)Start pyspark

```bash
pyspark --master spark://sparkmaster:7077 --deploy-mode client --packages io.delta:delta-core_2.12:1.0.0,io.delta:delta-sharing-spark_2.12:0.1.0 --conf spark.hadoop.fs.s3a.access.key=${AWS_ACCESS_KEY_ID} --conf spark.hadoop.fs.s3a.secret.key=${AWS_SECRET_ACCESS_KEY} --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem --conf spark.hadoop.fs.s3a.endpoint="${AWS_SERVER}:${AWS_PORT}" --conf spark.hadoop.fs.s3a.connection.ssl.enabled=false --conf spark.hadoop.fs.s3a.path.style.access=true --conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
```

### (Inside pyspark) Read json data and writa as delta table

```python
carDF = spark.read.json("s3://demo-s3-output/input/data/demo/spark/20210709/")
carDF.write.format("delta").save("s3://demo-s3-output/output/data/demo/spark/20210614/")

deltaDF = spark.read.format("delta").load("s3://demo-s3-output/output/data/demo/spark/20210614/")
deltaDF.show()
```

### (Inside pyspark) Read through delta sharing protocol

```python
import delta_sharing

profile_file = "file:///opt/airflow/delta.profile"

client = delta_sharing.SharingClient(profile_file)
client.list_all_tables()

table_url = profile_file + "#airflow.spark.table1"

sharingDF = delta_sharing.load_as_spark(table_url)
```

## You can also check the sharing server from outside pyspark

### (On localhost) Use CURL to read the sharing data

```bash
curl -H "Authorization: Bearer authTokenDeltaSharing432" -X POST  localhost:38080/delta-sharing/shares/airflow/schemas/spark/tables/table1/query
```

## Sparkshell without AWS credentials

`docker exec -ti s3-spark-delta-sharing_sparkshell_1 /bin/bash`

We use the sparkshell docker container (which contains spark) to execute the following commands:

```bash
mkdir -p /opt/sharing
echo '{
  "shareCredentialsVersion": 1,
  "endpoint": "http://delta:8080/delta-sharing/",
  "bearerToken": "authTokenDeltaSharing432"
}' > /opt/sharing/delta.profile

```

```bash
spark-shell --master spark://sparkmaster:7077 --deploy-mode client --packages io.delta:delta-core_2.12:1.0.0,io.delta:delta-sharing-spark_2.12:0.1.0
```

```scala
val profile_file = "file:///opt/sharing/delta.profile"

val table_url = profile_file + "#airflow.spark.table1"

val sharingDF = spark.read.format("deltaSharing").load(table_url)
sharingDF.show()
```

## Converted to a Airflow DAG

### DAG spark-s3-to-delta-with-delta-sharing created

A dag was created to store the data in a partitioned delta table format in S3. 

the profile file is already added to the airflow docker container in the whirl setup step.

#### Step 1 s3todelta.py

A spark job that:
- Reads the json data from S3.
- Adds a data column for partitioning.
- Writes the df as delta format to S3 partitioned by date.

#### Step 2 readdeltasharing.py

A Spark job that:
- Reads the data through Deltasharing server.
