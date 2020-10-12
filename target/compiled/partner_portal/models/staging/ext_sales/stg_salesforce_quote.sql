-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from partner_portal.ext_sales.salesforce_quote

),

remaned_src as (

    select
        opportunityid,
        createddate,
        buying_type__c,
        status,
        id,
        total_discount__c,
        HEARING_AID_RIGHT__C,
        HEARING_AID_LEFT__C,
--        datetime,
        selected_hearing_aid__c,
        first_appointment_confirmed__c

    from src

)

select * from remaned_src