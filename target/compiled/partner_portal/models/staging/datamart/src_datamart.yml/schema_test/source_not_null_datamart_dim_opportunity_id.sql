



select count(*) as validation_errors
from partner_portal.datamart.dim_opportunity
where id is null

