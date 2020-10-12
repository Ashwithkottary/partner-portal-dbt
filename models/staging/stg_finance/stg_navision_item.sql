-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from {{ source('stg_finance', 'navision_item') }}

),

remaned_src as (

    select
        no_
        ,country_code_iso3
        ,item_category_code
        ,manufacturer_code

    from src

)

select * from remaned_src
