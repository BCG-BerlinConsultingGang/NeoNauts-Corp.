/*
General Information on the table:
1. Primary key test successfully completed on transcation_id (all values are unique and not null).
2. ea_cardholderpresence, ea_merchant_country, ea_merchant_mcc, ea_merchant_city are only filled in for ATM, CARD_PAYMENT, and CARD_REFUND.
*/

WITH cleaned_transactions AS (
    SELECT
        CAST(REPLACE(transaction_id, "transaction_", "") AS integer) AS transaction_id,
        transactions_type,
        transactions_currency,
        amount_usd,
        transactions_state,
        ea_cardholderpresence,
        CAST(ea_merchant_mcc AS integer) AS ea_merchant_mcc,
        ea_merchant_country,
        direction,
        CAST(REPLACE(user_id, "user_", "") AS integer) AS user_id,
        DATE(created_date) AS transaction_date
    FROM {{ ref('stg_raw_neo_bank__transactions') }}
    WHERE transactions_state IN ("COMPLETED","PENDING")
),

aggregated AS (
    SELECT
        user_id,
        COUNT(*) AS total_transactions,
        ROUND(SUM(amount_usd), 3) AS total_amount_usd,
        ROUND(AVG(amount_usd), 3) AS average_amount_per_transaction_usd,
        MIN(transaction_date) AS first_transaction_date,
        MAX(transaction_date) AS last_transaction_date,
        DATE_DIFF(MAX(transaction_date), MIN(transaction_date), DAY) AS time_between_transactions,

        -- Transactions Type breakdown
        COUNTIF(transactions_type = "REFUND") AS transactions_type_refund,
        COUNTIF(transactions_type = "TAX") AS transactions_type_tax,
        COUNTIF(transactions_type = "CARD_REFUND") AS transactions_type_card_refund,
        COUNTIF(transactions_type = "FEE") AS transactions_type_fee,
        COUNTIF(transactions_type = "CASHBACK") AS transactions_type_cashback,
        COUNTIF(transactions_type = "ATM") AS transactions_type_atm,
        COUNTIF(transactions_type = "EXCHANGE") AS transactions_type_exchange,
        COUNTIF(transactions_type = "TOPUP") AS transactions_type_topup,
        COUNTIF(transactions_type = "TRANSFER") AS transactions_type_transfer,
        COUNTIF(transactions_type = "CARD_PAYMENT") AS transactions_type_card_payment,

        -- Direction breakdown
        COUNTIF(direction = "INBOUND") AS direction_inbound,
        COUNTIF(direction = "OUTBOUND") AS direction_outbound,

        -- Days since last activity:
        DATE_DIFF(DATE('2019-05-16'), MAX(transaction_date), DAY) AS days_since_last_transaction,

    FROM cleaned_transactions
    GROUP BY user_id
)

SELECT
    *,
    ROUND(SAFE_DIVIDE(total_transactions, time_between_transactions + 1), 3) AS avg_transactions_per_day,

    -- average in and outbound transactions

    ROUND(SAFE_DIVIDE(direction_inbound, time_between_transactions + 1), 3) AS avg_inbound,
    ROUND(SAFE_DIVIDE(direction_outbound, time_between_transactions + 1), 3) AS avg_outbound

FROM aggregated
