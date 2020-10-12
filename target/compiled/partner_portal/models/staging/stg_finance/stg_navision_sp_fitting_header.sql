-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from partner_portal.stg_finance.navision_sp_fitting_header

),

remaned_src as (

    select
        country_code_iso3
        ,salesforce_id
        ,no_

    from src

)

select * from remaned_src