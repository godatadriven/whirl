# Environment for DBT Athen and Glue services

TBD

## Data conversion

```python
import pyarrow.parquet as pq
table1 = pq.read_table("data/yellow_tripdata_2024-01.parquet")
pq.write_table(table1, "data/yellow_tripdata_2024-01.parquet.snappy", use_dictionary=False)
table2 = pq.read_table("data/yellow_tripdata_2024-02.parquet")
pq.write_table(table2, "data/yellow_tripdata_2024-02.parquet.snappy", use_dictionary=False)
```
