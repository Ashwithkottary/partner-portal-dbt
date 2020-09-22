



select count(*) as validation_errors
from (

    select
        partner_id

    from PARTNER_PORTAL.dbt_adhingra.stg_dim_opportunity
    where partner_id is not null
    group by partner_id
    having count(*) > 1

) validation_errors

