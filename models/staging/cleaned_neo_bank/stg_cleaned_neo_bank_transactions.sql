/*
General Information on the table
1. Primary key test successfully completed on transcation_id (all values are unique and not null).
2. ea_cardholderpresence, ea_merchant_country, ea_merchant_mcc, ea_merchant_city are only filled in for ATM, CARD_PAYMENT, and CARD_REFUND.
*/

SELECT
    CAST(replace(transaction_id, "transaction_", "") as INT64) as transaction_id,
    transactions_type,
    transactions_currency,
    amount_usd,
    transactions_state,
    ea_cardholderpresence,
    CAST(ea_merchant_mcc as INT64) as ea_merchant_mcc,
    ea_merchant_country,
    direction,
    replace(user_id, "user_", "") as user_id,
    date(created_date) as transaction_date
FROM {{ ref('stg_raw_neo_bank__transactions') }}