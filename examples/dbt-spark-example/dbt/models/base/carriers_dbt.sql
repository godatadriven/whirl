select 
    Code as carrier_id,
    Description as carrier_name
from 
    {{ source('landing_zone_flights', 'carriers') }}