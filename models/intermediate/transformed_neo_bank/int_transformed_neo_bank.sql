-- We decided to use INNER JOIN, instead of LEFT JOIN. We will lose 900 users, from which we had no transaction data at all.

-- JOIN of users and notifications table inside subquery

with subquery as(

    select 
        u.*,
        n.* except(user_id),
        from {{ ref('int_cleaned_neo_bank_users') }} as u
            left join {{ ref('int_cleaned_neo_bank_notifications') }} as n
            USING(user_id)
) 

-- additional JOIN with transactions table

select 
    s.*, 
    t.* except(user_id),
    DATE_DIFF(t.last_transaction_date, s.sign_up_date, DAY) as active_timeframe
    from subquery as s 
        INNER join {{ ref('int_cleaned_neo_bank_transactions') }} as t 
        USING(user_id)
        