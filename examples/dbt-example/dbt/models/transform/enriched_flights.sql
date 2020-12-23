with flights as (
    select
        *
    from 
        {{ ref('flights_dbt') }}
), airports as  (
    select
        *
    from
        {{ ref('airports_dbt') }}
), carriers as  (
    select
        *
    from
        {{ ref('carriers_dbt') }}
) 

select
    flights.*,
    carriers.carrier_name,
    a1.airport_name as origin_airport_name,
    a2.airport_name as destination_airport_name
from 
    flights
    join carriers
        on flights.carrier_id = carriers.carrier_id
    join airports a1
        on flights.origin_airport_id = a1.airport_id
    join airports a2
        on flights.destination_airport_id = a2.airport_id