/*
General Information on the table:
1. Primary key test successfully completed on transcation_id (all values are unique and not null).
2. ea_cardholderpresence, ea_merchant_country, ea_merchant_mcc, ea_merchant_city are only filled in for ATM, CARD_PAYMENT, and CARD_REFUND.
*/

SELECT
    CAST(replace(transaction_id, "transaction_", "") as INT64) as transaction_id, -- remove "transaction_" from the id and transform to integer
    transactions_type,
    transactions_currency,
    amount_usd,
    transactions_state,
    ea_cardholderpresence,
    CAST(ea_merchant_mcc as INT64) as ea_merchant_mcc, -- transform ea_merchant_cc to integer
    ea_merchant_country,
    direction,
    replace(user_id, "user_", "") as user_id, -- remove "user_" from the id and transform to integer
    date(created_date) as transaction_date
FROM {{ ref('stg_raw_neo_bank__transactions') }}

Select
    distinct transactions_type,
    count (*) as nb
from {{ ref('stg_raw_neo_bank__transactions') }}
group by transactions_type
order by nb