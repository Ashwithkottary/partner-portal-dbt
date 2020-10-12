



select count(*) as validation_errors
from PARTNER_PORTAL.dbt_adhingra.stg_dim_opportunity
where id is null

