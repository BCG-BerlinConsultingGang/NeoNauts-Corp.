with 

source as (

    select * from {{ source('raw_neo_bank', 'notifications') }}

),

renamed as (

    select
        reason,
        channel,
        status,
        user_id,
        created_date

    from source

)

select * from renamed
