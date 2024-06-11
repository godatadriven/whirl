-- metricflow_time_spine.sql
with

days as (

    {{ dbt_utils.date_spine(
            "day",
            "date_add('year', -10, current_date)",
            "current_date"
        )
    }}


),

cast_to_date as (

    select cast(date_day as date) as date_day

    from days

)

select * from cast_to_date
