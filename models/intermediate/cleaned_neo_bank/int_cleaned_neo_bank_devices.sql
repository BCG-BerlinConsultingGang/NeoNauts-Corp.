-- want to get rid of unclear device brands: "unknown" & "brand"

SELECT  cast(regexp_replace(user_id, '^user_', '') as integer) as user_id, 
device_brand, 
CAST(device_brand = "Apple" AS INT64) AS apple_user,
CAST(device_brand = "Android" AS INT64) AS android_user,
FROM {{ ref('stg_raw_neo_bank__devices') }}
WHERE device_brand IN ('Apple', 'Android')