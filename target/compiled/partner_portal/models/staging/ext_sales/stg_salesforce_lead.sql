-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from partner_portal.ext_sales.salesforce_lead

),

remaned_src as (

    select
        id,
        convertedopportunityid,
        dw_modified_at

    from src

)

select * from remaned_src