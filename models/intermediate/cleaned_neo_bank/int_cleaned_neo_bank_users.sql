/*

change user_id by deleting user_:

select 
cast(regexp_replace(user_id, '^user_', '') as integer) as user_id, * EXCEPT(user_id)
from {{ ref('stg_raw_neo_bank__users') }}

checking for NULL values:

select 
*
from {{ ref('stg_raw_neo_bank__users') }}
where num_successful_referrals is NULL

Results: 
-> MANY null values for: attributes_notifications_marketing_push, attributes_notifications_marketing_email
-> How to treat them? We have 0 and 1 values. Makes sense to plug in 0 for all 0s.

coalesce(attributes_notifications_marketing_push, 0) as ...
coalesce(attributes_notifications_marketing_email, 0) as...

-> They are floats, but integers would be cooler, so let us also cast them to integer as well

(cast(attributes_notifications_marketing_push) as integer) as notifications_marketing_push
(cast(attributes_notifications_marketing_email) as integer as notifications_marketing_email

After several checks we decided to NOT INCLUDE the notification tables, as the many (6600) NULL values are not possible to evaluate and analyse properly.

Detailed check of city column:
 
-> How to treat PLZ? Better to just ignore cities, as this might be unpossible to use as a feature

-- CTE:

*/

with subquery as (
    select 
        cast(regexp_replace(user_id, '^user_', '') as integer) as user_id,
        birth_year,
        country,
        city,
        CAST(user_settings_crypto_unlocked as BOOL) as crypto_unlocked,
        CASE
            WHEN plan IN ('METAL_FREE', 'PREMIUM_FREE') THEN 'STANDARD'
            WHEN plan = 'PREMIUM_OFFER' THEN 'PREMIUM'
        ELSE plan
        END AS plan,
        num_contacts,
        num_referrals,
        num_successful_referrals,
        date(created_date) as sign_up_date,
        cast(attributes_notifications_marketing_push as integer) as notifications_marketing_push,
        cast(attributes_notifications_marketing_email as integer) as notifications_marketing_email
    from {{ ref('stg_raw_neo_bank__users') }}
)

select
    * except(notifications_marketing_push, notifications_marketing_email, city),
    IF(plan = 'STANDARD', FALSE, TRUE) as paid_subscription
from subquery