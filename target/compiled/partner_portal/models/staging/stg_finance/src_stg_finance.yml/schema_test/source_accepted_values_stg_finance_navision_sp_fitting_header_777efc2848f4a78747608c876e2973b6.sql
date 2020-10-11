




with all_values as (

    select distinct
        country_code_iso3 as value_field

    from partner_portal.stg_finance.navision_sp_fitting_header

),

validation_errors as (

    select
        value_field

    from all_values
    where value_field not in (
        'CAN','CHE','CHN','DEU','FRA','GBR','HKG','IND','JPN','KOR','MYS','N/A','NLD','SGP','THA','USA','ZAF''
    )
)

select count(*) as validation_errors
from validation_errors

