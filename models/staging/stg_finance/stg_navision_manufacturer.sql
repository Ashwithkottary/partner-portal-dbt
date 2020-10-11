-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from {{ source('stg_finance', 'navision_manufacturer') }}

),

remaned_src as (

    select
        name
        ,country_code_iso3
        ,code

    from src

)

select * from remaned_src
