select 
    FL_DATE as flight_date,
    OP_UNIQUE_CARRIER as carrier_id,
    ORIGIN_AIRPORT_ID as origin_airport_id,
    ORIGIN_AIRPORT_SEQ_ID as origin_airport_seq_id,
    ORIGIN_CITY_MARKET_ID as origin_city_market_id,
    ORIGIN_CITY_NAME as origin_city_name,
    DEST_AIRPORT_ID as destination_airport_id,
    DEST_AIRPORT_SEQ_ID as destination_seq_id,
    DEST_CITY_MARKET_ID as destination_city_market_id,
    DEST_CITY_NAME as destination_city_name,
    DEP_DELAY_NEW as departure_delay,
    ARR_DELAY_NEW as arrival_delay,
    CANCELLED as cancelled,
    DIVERTED as diverted,
    ACTUAL_ELAPSED_TIME as actual_elapsed_time,
    DISTANCE as distance
from 
    {{ source('landing_zone_flights', 'flights_data') }}
{% if target.name == 'dev' %}
    where fl_date <= '2019-01-03'
{% endif %}
