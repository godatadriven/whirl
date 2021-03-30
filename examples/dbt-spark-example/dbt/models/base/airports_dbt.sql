select 
    Code as airport_id,
    Description as airport_name
from 
    {{ source('landing_zone_flights', 'airports') }}