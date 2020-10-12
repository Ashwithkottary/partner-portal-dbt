-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from {{ source('stg_finance', 'navision_sp_fitting_line') }}

),

remaned_src as (

    select
        fitting_process_no_
        ,no_
        ,country_code_iso3
    from src

)

select * from remaned_src
