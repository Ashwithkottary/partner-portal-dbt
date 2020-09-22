
  create or replace  view PARTNER_PORTAL.dbt_adhingra.stg_dim_partner_subsdiary  as (
    select
    id 
from partner_portal.datamart.dim_partner_subsidiary

-- source has syntax Source {'schema_name','table_name'}
  );
