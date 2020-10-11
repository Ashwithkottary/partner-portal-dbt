



select count(*) as validation_errors
from partner_portal.stg_finance.navision_sp_fitting_header
where salesforce_id is null

