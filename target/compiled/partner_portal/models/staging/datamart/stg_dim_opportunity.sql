-- source has syntax Source {'schema_name','table_name'}
with src as (

    select * from partner_portal.datamart.dim_opportunity

),

remaned_src as (

    select
        id,
        partner_id,
        country_code_iso3,
        finished_date,
        first_appointment_date,
        partner_service_premium,
        days_to_first_appointment,
        stage_name,
        created_date,
        gross_process_duration,
        nav_number_of_hearing_aids,
        nav_revenue_local

    from src

)

select * from remaned_src