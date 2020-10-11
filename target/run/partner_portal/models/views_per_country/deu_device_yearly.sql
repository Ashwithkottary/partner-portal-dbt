
  create or replace  view PARTNER_PORTAL.dbt_adhingra.deu_device_yearly  as (
    WITH sf_final_quote AS (
    -- Get id/discount__c of the "final final" quote
      SELECT
        id,
        total_discount__c
      FROM PARTNER_PORTAL.dbt_adhingra.stg_salesforce_quote q INNER JOIN
        -- Sub-query defines the "final final" quote on a given opportunity. Def provided by Oliver O.
        (
          SELECT
            opportunityid,
            max(createddate) AS createddate
          FROM PARTNER_PORTAL.dbt_adhingra.stg_salesforce_quote
          WHERE status = 'Final Quote' AND coalesce(hearing_aid_right__c, hearing_aid_left__c) IS NOT NULL
          -- WHERE status = 'Final Quote' AND total__c >= 1000     NOTE: OLD Definition
          GROUP BY 1
        ) max_quote ON q.opportunityid = max_quote.opportunityid AND q.createddate = max_quote.createddate
  ), mfr_counts AS (
      SELECT
        fh.country_code_iso3,
        fh.salesforce_id,
        mfr.name       AS manufacturer,
        count(itm.no_) AS number_of_devices
      FROM PARTNER_PORTAL.dbt_adhingra.stg_navision_sp_fitting_header fh
        INNER JOIN PARTNER_PORTAL.dbt_adhingra.stg_navision_sp_fitting_line fl
          ON fh.no_ = fl.fitting_process_no_ AND fh.country_code_iso3 = fl.country_code_iso3
        INNER JOIN sf_final_quote fq ON fh.salesforce_id = fq.id
        LEFT JOIN PARTNER_PORTAL.dbt_adhingra.stg_navision_item AS itm
          ON fl.no_ = itm.no_ AND fl.country_code_iso3 = itm.country_code_iso3 AND itm.item_category_code = 'HA'
        LEFT JOIN PARTNER_PORTAL.dbt_adhingra.stg_navision_manufacturer mfr
          ON itm.country_code_iso3 = mfr.country_code_iso3 AND itm.manufacturer_code = mfr.code
      WHERE fh.country_code_iso3 IN ('DEU') AND mfr.code IS NOT NULL
      GROUP BY 1, 2, 3
  )
  SELECT
    p.parent_id,
    p.id,
    mfr_counts.manufacturer,
    date_trunc('year', cast(o.finished_date as timestamp)) :: DATE AS date_month,
    sum(number_of_devices)                      AS number_of_devices
  FROM mfr_counts
    INNER JOIN PARTNER_PORTAL.dbt_adhingra.stg_salesforce_quote as q ON mfr_counts.salesforce_id = q.id
    INNER JOIN PARTNER_PORTAL.dbt_adhingra.stg_dim_opportunity as o ON q.opportunityid = o.id
    LEFT JOIN PARTNER_PORTAL.dbt_adhingra.stg_dim_partner_subsidiary as p ON o.partner_id = p.id
  WHERE o.stage_name = 'closed and won' -- AND date_trunc('month', o.finished_date) :: DATE >= '2017-10-01'
  GROUP BY 1, 2, 3, 4
  ORDER BY 4 DESC
  );
