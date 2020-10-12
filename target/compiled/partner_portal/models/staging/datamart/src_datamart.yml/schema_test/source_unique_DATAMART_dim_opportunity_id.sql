



select count(*) as validation_errors
from (

    select
        id

    from partner_portal.DATAMART.dim_opportunity
    where id is not null
    group by id
    having count(*) > 1

) validation_errors

