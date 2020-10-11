-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from partner_portal.ext_sales.salesforce_opportunity

),

remaned_src as (

    select
        createddate,
        id,
        ISO_COUNTRY_CODE_CUSTOMER__C,
        pak_partnerid__c,
        ab_helper_first_appointment__c,
        partner_service_premium__c,
        time_to_first_appointment__c,
        accountid,
        dw_modified_at

    from src

)

select * from remaned_src