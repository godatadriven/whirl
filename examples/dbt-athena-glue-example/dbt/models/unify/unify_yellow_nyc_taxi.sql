{{
    config(
        materialized="table",
        table_type="iceberg",
        format="parquet",
    )
}}

with
    tripdata as (
        select *, row_number() over (partition by vendorid, tpep_pickup_datetime) as rn
        from {{ source("yellow_nyc_taxi_source", "yellow") }}
        where vendorid is not null
    ),
    final as (
        select
            -- identifiers
            {{ dbt_utils.generate_surrogate_key(["vendorid", "tpep_pickup_datetime"]) }}
            as tripid,
            cast(vendorid as integer) as vendorid,
            cast(ratecodeid as integer) as ratecodeid,
            cast(pulocationid as integer) as pickup_locationid,
            cast(dolocationid as integer) as dropoff_locationid,

            -- timestamps
            cast(tpep_pickup_datetime as timestamp(6)) as pickup_datetime,
            cast(tpep_dropoff_datetime as timestamp(6)) as dropoff_datetime,

            -- trip info
            store_and_fwd_flag,
            cast(passenger_count as integer) as passenger_count,
            cast(trip_distance as double) as trip_distance,
            -- yellow cabs are always street-hail
            1 as trip_type,

            -- payment info
            cast(fare_amount as double) as fare_amount,
            cast(extra as double) as extra,
            cast(mta_tax as double) as mta_tax,
            cast(tip_amount as double) as tip_amount,
            cast(tolls_amount as double) as tolls_amount,
            cast(0 as double) as ehail_fee,
            cast(improvement_surcharge as double) as improvement_surcharge,
            cast(total_amount as double) as total_amount,
            cast(payment_type as integer) as payment_type,
            cast(congestion_surcharge as double) as congestion_surcharge

        from tripdata
        where rn = 1
    )

select *
from final
