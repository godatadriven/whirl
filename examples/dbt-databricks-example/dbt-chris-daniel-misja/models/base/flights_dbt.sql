select 
    fl_date as flight_date,
    op_unique_carrier as carrier_id,
    origin_airport_id,
    origin_airport_seq_id,
    origin_city_market_id,
    origin_city_name,
    dest_airport_id as destination_airport_id,
    dest_airport_seq_id as destination_seq_id,
    dest_city_market_id as destination_city_market_id,
    dest_city_name as destination_city_name,
    dep_delay_new as departure_delay,
    arr_delay_new as arrival_delay,
    cancelled,
    diverted,
    actual_elapsed_time,
    distance
from 
    {{ source('default', 'flights') }}
{% if target.name == 'dev' %}
    where fl_date <= '2019-01-03'
{% endif %}
