



select count(*) as validation_errors
from (

    select
        id

    from PARTNER_PORTAL.dbt_adhingra.stg_dim_opportunity
    where id is not null
    group by id
    having count(*) > 1

) validation_errors

