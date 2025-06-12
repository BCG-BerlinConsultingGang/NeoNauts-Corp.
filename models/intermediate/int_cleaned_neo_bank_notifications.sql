/* --------------------------------------------------- Comment Start -----------------------------------------------------------

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


----------------------------------------Comment End */--------------------------------------------

-- models/notifications_summary.sql

-- models/notifications_summary.sql

WITH base AS (
    SELECT
        CAST(REGEXP_EXTRACT(user_id, r'user_(\d+)') AS integer) AS user_id,
        reason,
        channel,
        created_date
    FROM {{ ref('stg_raw_neo_bank__notifications') }}
    WHERE status = 'SENT'
),

reason_counts AS (
    SELECT
        user_id,
        reason,
        COUNT(*) AS reason_count
    FROM base
    GROUP BY user_id, reason
),

most_frequent_reason AS (
    SELECT
        user_id,
        ARRAY_AGG(reason ORDER BY reason_count DESC LIMIT 1)[OFFSET(0)] AS most_frequent_reason
    FROM reason_counts
    GROUP BY user_id
)

SELECT 
    b.user_id,

    -- First and Last SENT notification dates
    FORMAT_DATE('%Y-%m-%d', DATE(MIN(b.created_date))) AS first_notification,
    FORMAT_DATE('%Y-%m-%d', DATE(MAX(b.created_date))) AS last_notification,

    -- Duration in days between first and last
    DATE_DIFF(DATE(MAX(b.created_date)), DATE(MIN(b.created_date)), DAY) AS notification_duration_days,

    -- Count of all SENT notifications
    COUNT(*) AS nb_notifications,

    -- Channel-specific counts
    COUNTIF(b.channel = 'SMS') AS nb_sms,
    COUNTIF(b.channel = 'PUSH') AS nb_push,
    COUNTIF(b.channel = 'EMAIL') AS nb_email,

    -- Most frequent reason
    mfr.most_frequent_reason

FROM base AS b
LEFT JOIN most_frequent_reason mfr ON b.user_id = mfr.user_id
GROUP BY b.user_id, mfr.most_frequent_reason
