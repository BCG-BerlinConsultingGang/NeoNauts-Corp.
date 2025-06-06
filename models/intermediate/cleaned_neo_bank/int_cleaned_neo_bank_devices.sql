-- want to get rid of unclear device brands: "unknown" & "brand"

SELECT  user_id, device_brand
FROM {{ ref('stg_raw_neo_bank__devices') }}
WHERE device_brand IN ('Apple', 'Android')