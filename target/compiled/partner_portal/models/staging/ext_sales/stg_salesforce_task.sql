-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from partner_portal.ext_sales.salesforce_task

),

remaned_src as (

    select
        opportunity__c,
        worth_recognized__c

    from src

)

select * from remaned_src