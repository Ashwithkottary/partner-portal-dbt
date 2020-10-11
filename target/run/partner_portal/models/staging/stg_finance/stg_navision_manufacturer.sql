
  create or replace  view PARTNER_PORTAL.dbt_adhingra.stg_navision_manufacturer  as (
    -- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from partner_portal.stg_finance.navision_manufacturer

),

remaned_src as (

    select
        name
        ,country_code_iso3
        ,code

    from src

)

select * from remaned_src
  );
