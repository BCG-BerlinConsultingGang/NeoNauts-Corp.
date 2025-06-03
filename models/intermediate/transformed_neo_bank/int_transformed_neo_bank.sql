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
    t.* except(user_id)
    from subquery as s 
        left join {{ ref('int_cleaned_neo_bank_transactions') }} as t 
        USING(user_id)