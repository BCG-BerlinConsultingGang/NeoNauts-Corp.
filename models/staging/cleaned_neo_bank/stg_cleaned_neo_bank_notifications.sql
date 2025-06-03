SELECT 
    *
FROM {{ ref('stg_raw_neo_bank__notifications') }}

------------------------------------------------------ NULL TESTS - START  -----------------------------------------------------
--IS-Null test for column channel
SELECT 
 channel      
FROM {{ ref('stg_raw_neo_bank__notifications') }}
WHERE channel IS NULL
--> no null values

--IS-Null test for column status
SELECT 
    status
FROM {{ ref('stg_raw_neo_bank__notifications') }}
WHERE status IS NULL
--> no null values 

SELECT 
    user_id
FROM {{ ref('stg_raw_neo_bank__notifications') }}
WHERE user_id IS NULL
--> no null values 

SELECT 
    reason
FROM {{ ref('stg_raw_neo_bank__notifications') }}
WHERE reason IS NULL
--> no null values 
------------------------------------------------------ NULL TESTS - END -----------------------------------------------------

-- Three distinct channels: push, email, SMS
SELECT 
    distinct channel
FROM {{ ref('stg_raw_neo_bank__notifications') }}

-- 17 distinct reasons 
SELECT 
   distinct reason
FROM {{ ref('stg_raw_neo_bank__notifications') }}

-- Distribution of notifications across channels
SELECT 
    channel,
    COUNT(channel) as nb_notfications
FROM {{ ref('stg_raw_neo_bank__notifications') }}
GROUP BY channel
ORDER BY nb_notfications DESC 
