
  create or replace  view PARTNER_PORTAL.dbt_adhingra.deu_fd_yearly  as (
    WITH fd_metrics AS (
      SELECT
        p.parent_id,
        p.id,
        date_trunc('year', cast(o.finished_date as date)) :: DATE AS date_year,        
        case when sum(case when o.stage_name in ('closed and won','closed and lost') then 1 else 0 end) > 0 then
        (sum(case when o.stage_name = 'closed and won' then 1 else 0 END) / sum(case when o.stage_name in ('closed and won','closed and lost') then 1 else 0 END) ):: NUMERIC end as conversion_rate,
        
/*    -- conversion rate in kirll's code
        CASE WHEN COUNT(o.id)
                    FILTER (WHERE stage_name =
                                  'closed and won') > 0 OR COUNT(o.id)
                                                             FILTER (WHERE stage_name =
                                                                           'closed and lost') > 0
          THEN
            COUNT(o.id)
              FILTER (WHERE stage_name = 'closed and won') :: NUMERIC / (COUNT(o.id)
                                                                           FILTER (WHERE stage_name =
                                                                                         'closed and won') :: NUMERIC
                                                                         + COUNT(o.id)
                                                                           FILTER (WHERE stage_name =
                                                                                         'closed and lost') :: NUMERIC) END AS conversion_rate,
*/
        case when
         sum(case when o.stage_name = 'closed and won' and (o.gross_process_duration IS NULL OR o.gross_process_duration <= 170) then 1 else 0 END) > 0
        THEN
        sum(case when o.stage_name = 'closed and won' AND (o.gross_process_duration IS NULL OR o.gross_process_duration <= 170) then o.gross_process_duration else 0 end) / sum(case when 
        o.stage_name = 'closed and won' AND (o.gross_process_duration IS NULL OR o.gross_process_duration <= 170) then 1 else 0 end) end as gross_process_duration,


/*
        CASE WHEN count(o.id)
                    FILTER (WHERE stage_name =
                                  'closed and won' AND
                                  (o.gross_process_duration IS NULL OR o.gross_process_duration <= 170)) > 0
          THEN sum(o.gross_process_duration)
                 FILTER (WHERE stage_name = 'closed and won' AND
                               (o.gross_process_duration IS NULL OR o.gross_process_duration <= 170)) / count(o.id)
                 FILTER (WHERE stage_name =
                               'closed and won' AND
                               (o.gross_process_duration IS NULL OR o.gross_process_duration <= 170))
        ELSE 0 END   AS gross_process_duration,
*/ --gross_process_duration

case when
sum(case when o.stage_name = 'closed and won' then o.nav_number_of_hearing_aids end ) > 0
then  
sum(case when o.stage_name = 'closed and won' then o.nav_revenue_local end) /
sum(case when o.stage_name = 'closed and won' then o.nav_number_of_hearing_aids end)
else 0 end as asp

/*        CASE
        WHEN sum(o.nav_number_of_hearing_aids) FILTER (WHERE stage_name = 'closed and won') > 0
          THEN (sum(o.nav_revenue_local)
                  FILTER (WHERE stage_name = 'closed and won') / sum(o.nav_number_of_hearing_aids)
                  FILTER (WHERE stage_name = 'closed and won'))
        ELSE 0
        END   AS asp
*/
      FROM PARTNER_PORTAL.dbt_adhingra.stg_dim_opportunity AS o
        JOIN PARTNER_PORTAL.dbt_adhingra.stg_dim_partner_subsidiary AS p ON o.partner_id = p.id
            WHERE o.country_code_iso3 = 'DEU' AND o.finished_date IS NOT NULL
      GROUP BY 1, 2, 3
  ),
ranked AS (
      SELECT
        fd.parent_id,
        fd.id,
        fd.date_year,
        conversion_rate,
        asp,
        gross_process_duration,
        row_number()
        OVER (
          PARTITION BY fd.date_year
          ORDER BY conversion_rate DESC )                             AS rank_conversion_rate,
        row_number()
        OVER (
          PARTITION BY fd.date_year
          ORDER BY asp DESC )                                         AS rank_asp,
        row_number()
        OVER (
          PARTITION BY fd.date_year
          ORDER BY nullif(gross_process_duration, 0) ASC NULLS LAST ) AS rank_gross_process_duration
      FROM fd_metrics fd
        LEFT JOIN PARTNER_PORTAL.dbt_adhingra.deu_ocd_yearly ocd
          ON fd.id = ocd.id AND fd.date_year = ocd.date_year
      WHERE ocd.customer_potential >= 10
  ), avg AS (
      SELECT
        date_year,
        avg(case when rank_conversion_rate <= 20 then conversion_rate end) AS top20_conversion_rate,
/*        avg(conversion_rate)
          FILTER (WHERE rank_conversion_rate <= 20)        AS top20_conversion_rate, */
        avg(conversion_rate) + 0.07                        AS market_avg_conversion_rate, -- Pad the market average as per P.C. by 7% for partner motivation
        avg(case when rank_asp <=20 then asp end) as top20_asp,
/*        avg(asp)
          FILTER (WHERE rank_asp <= 20)                    AS top20_asp, 
          */
        avg(asp) AS market_avg_asp,
        avg(case when rank_gross_process_duration <= 20 then gross_process_duration end) as top20_gross_process_duration,
/*        avg(gross_process_duration)
          FILTER (WHERE rank_gross_process_duration <= 20) AS top20_gross_process_duration,
          */
        avg(nullif(gross_process_duration, 0))             AS market_avg_gross_process_duration
      FROM ranked
      GROUP BY date_year
  ), top1 AS (
      SELECT
        date_year,
        conversion_rate      AS top1_conversion_rate
      FROM ranked
      WHERE rank_conversion_rate = 1
  )
  SELECT DISTINCT
    fd.parent_id,
    fd.id,
    fd.date_year,
    fd.conversion_rate,
    fd.asp,
    fd.gross_process_duration,
    a.market_avg_asp,
    a.market_avg_conversion_rate,
    a.market_avg_gross_process_duration,
    a.top20_asp,
    a.top20_conversion_rate,
    a.top20_gross_process_duration,
    r.rank_asp,
    r.rank_conversion_rate,
    r.rank_gross_process_duration,
    t.top1_conversion_rate
  FROM fd_metrics fd
    LEFT JOIN ranked AS r ON fd.id = r.id AND fd.date_year = r.date_year
    LEFT JOIN avg a ON a.date_year = fd.date_year
    LEFT JOIN top1 t ON t.date_year = fd.date_year
  );
