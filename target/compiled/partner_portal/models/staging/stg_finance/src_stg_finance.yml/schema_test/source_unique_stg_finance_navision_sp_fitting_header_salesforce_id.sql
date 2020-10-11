



select count(*) as validation_errors
from (

    select
        salesforce_id

    from partner_portal.stg_finance.navision_sp_fitting_header
    where salesforce_id is not null
    group by salesforce_id
    having count(*) > 1

) validation_errors

