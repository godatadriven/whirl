SELECT type AS car_brand, COUNT(*) AS n_records
FROM {{ source("public", "api") }}
GROUP BY type
