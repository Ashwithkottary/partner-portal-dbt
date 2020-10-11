



select count(*) as validation_errors
from PARTNER_PORTAL.dbt_adhingra.stg_dim_partner_subsidiary
where id is null

