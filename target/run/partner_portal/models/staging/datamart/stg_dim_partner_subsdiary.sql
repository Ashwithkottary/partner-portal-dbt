
  create or replace  view PARTNER_PORTAL.dbt_adhingra.stg_dim_partner_subsdiary  as (
    -- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from partner_portal.datamart.dim_partner_subsidiary

),

remaned_src as (

    select
        id as id,
        parent_id

    from src

)

select * from remaned_src
  );
