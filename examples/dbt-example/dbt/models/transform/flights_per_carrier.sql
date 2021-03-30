select
    carrier_id,
    carrier_name,
    count(*) as n_flights
from 
    {{ ref('enriched_flights' )}}
group by
    carrier_id, carrier_name 
order by 
    n_flights desc 
