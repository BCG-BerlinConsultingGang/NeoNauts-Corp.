with 

source as (

    select * from {{ source('raw_neo_bank', 'devices') }}

),

renamed as (

    select
        string_field_0 as device_brand,
        string_field_1 as user_id

    from source

)

select * from renamed
