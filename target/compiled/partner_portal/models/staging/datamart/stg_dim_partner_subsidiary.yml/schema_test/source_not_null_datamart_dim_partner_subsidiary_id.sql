



select count(*) as validation_errors
from partner_portal.datamart.dim_partner_subsidiary
where id is null

