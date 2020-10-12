-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from partner_portal.ext_sales.salesforce_account

),

remaned_src as (

    select
        id,
        parentid,
        dw_modified_at,
        billingpostalcode

    from src

)

select * from remaned_src