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
)

SELECT
    user_id,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount_usd),2) AS total_amount_usd,
    ROUND(AVG(amount_usd),2) AS average_amount_per_transaction_usd,
    MIN(transaction_date) AS first_transaction_date,
    MAX(transaction_date) AS last_transaction_date,

    -- Transactions Type breakdown (e.g. "card_payment", "refund" etc.)
    COUNTIF(transactions_type = 'REFUND') AS transactions_type_purchase,
    COUNTIF(transactions_type = 'TAX') AS transactions_type_withdrawal,
    COUNTIF(transactions_type = 'CARD_REFUND') AS transactions_type_deposit,
    COUNTIF(transactions_type = 'FEE') AS transactions_type_purchase,
    COUNTIF(transactions_type = 'CASHBACK') AS transactions_type_withdrawal,
    COUNTIF(transactions_type = 'ATM') AS transactions_type_deposit,
    COUNTIF(transactions_type = 'EXCHANGE') AS transactions_type_purchase,
    COUNTIF(transactions_type = 'TOPUP') AS transactions_type_withdrawal,
    COUNTIF(transactions_type = 'TRANSFER') AS transactions_type_deposit,
    COUNTIF(transactions_type = 'CARD_PAYMENT') AS transactions_type_deposit,

    -- Direction breakdown (e.g., "inbound", "outbound")
    COUNTIF(direction = 'inbound') AS direction_inbound,
    COUNTIF(direction = 'outbound') AS direction_outbound

FROM cleaned_transactions
GROUP BY user_id
