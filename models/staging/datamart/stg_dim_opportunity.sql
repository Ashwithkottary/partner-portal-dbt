-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from {{ source('datamart', 'dim_opportunity') }}

),

remaned_src as (

    select
        id,
        partner_id,
        country_code_iso3,
        finished_date,
        first_appointment_date,
        partner_service_premium,
        days_to_first_appointment

    from src

)

select * from remaned_src
