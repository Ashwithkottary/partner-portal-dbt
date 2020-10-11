-- uses only dim_opp and dim_partner subsidiary, calculates ongoing potential and avg_days_to_first_appointment +network
WITH ocd_metrics AS (
      SELECT
        p.parent_id,
        p.id,
        date_trunc('year', cast(o.created_date as timestamp)) :: DATE                                               AS date_year,
        count(o.id)                                                                              AS customer_potential,
        count(case when o.stage_name NOT IN ('in process', 'appointment to be made', 'on hold') then o.id end) AS ongoing_potential,
        avg(case when o.days_to_first_appointment IS NOT NULL AND o.days_to_first_appointment < 60 then o.days_to_first_appointment end)  AS avg_days_to_first_appointment
      FROM {{ref('stg_dim_opportunity')}} as o
        LEFT JOIN {{ref('stg_dim_partner_subsidiary')}} as p ON o.partner_id = p.id
      WHERE o.country_code_iso3 = 'DEU' AND p.id IS NOT NULL
      GROUP BY 1, 2, 3
  ), ranked AS (
      SELECT
        ocd.*,
        row_number()
        OVER (
          PARTITION BY ocd.date_year
          ORDER BY avg_days_to_first_appointment ASC ) AS avg_days_to_first_appointment_rank,
        row_number()
        OVER (
          PARTITION BY ocd.date_year
          ORDER BY customer_potential DESC )           AS customer_potential_rank
      FROM ocd_metrics ocd
  ), top20 AS (
      SELECT
        date_year,
        avg(case when avg_days_to_first_appointment_rank <= 20 then avg_days_to_first_appointment end) AS top20_avg_days_to_first_appointment,
        avg(case when customer_potential_rank <= 20 then customer_potential end) AS top20_customer_potential
      FROM ranked
      GROUP BY 1
  ), market_avg AS (
      SELECT
        date_year,
        avg(customer_potential)            AS market_avg_customer_potential,
        avg(avg_days_to_first_appointment) AS market_avg_days_to_first_appointment
      FROM ocd_metrics
      GROUP BY 1
  ) SELECT
      ocd.*,
      top20.top20_avg_days_to_first_appointment,
      top20_customer_potential,
      market_avg_customer_potential,
      market_avg_days_to_first_appointment
    FROM ocd_metrics ocd
      LEFT JOIN top20 ON ocd.date_year = top20.date_year
      LEFT JOIN market_avg ON ocd.date_year = market_avg.date_year
