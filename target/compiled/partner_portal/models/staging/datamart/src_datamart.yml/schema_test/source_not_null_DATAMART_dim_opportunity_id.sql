



select count(*) as validation_errors
from partner_portal.DATAMART.dim_opportunity
where id is null

