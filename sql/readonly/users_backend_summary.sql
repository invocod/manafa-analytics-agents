-- users_backend_summary: production backend users over the last 28 complete days, per platform and all platforms (ROLLUP row 'all'). Aggregated, no PII.
-- A user active on two platforms counts once in 'all'. Amounts SAR only (never summed across currencies).
WITH b AS (SELECT DATE_SUB(MAX(DATE(occurred_at,'Asia/Riyadh')), INTERVAL 1 DAY) AS data_end FROM `databases-472111.manafa_financing.mi_analytics_events`),
e AS (
  SELECT event_name, COALESCE(JSON_VALUE(context.platform),'unknown') AS p, profile_id,
    SAFE_CAST(JSON_VALUE(payload.is_auto_invested) AS BOOL) AS auto, SAFE_CAST(JSON_VALUE(payload.is_first_investment) AS BOOL) AS first_inv,
    JSON_VALUE(payload.currency) AS cur, SAFE_CAST(JSON_VALUE(payload.amount) AS NUMERIC) AS amt, b.data_end
  FROM `databases-472111.manafa_financing.mi_analytics_events`, b
  WHERE DATE(occurred_at,'Asia/Riyadh') BETWEEN DATE_SUB(b.data_end, INTERVAL 27 DAY) AND b.data_end AND profile_id IS NOT NULL)
SELECT IF(GROUPING(p)=1,'all',p) AS platform, ANY_VALUE(data_end) AS data_end,
  COUNT(DISTINCT profile_id) AS active_users,
  COUNT(DISTINCT IF(event_name='registration_completed',profile_id,NULL)) AS registered,
  COUNT(DISTINCT IF(event_name='login_completed',profile_id,NULL)) AS logged_in,
  COUNTIF(event_name='login_completed') AS logins,
  COUNT(DISTINCT IF(event_name='kyc_completed',profile_id,NULL)) AS kyc_done,
  COUNT(DISTINCT IF(event_name='deposit_success',profile_id,NULL)) AS depositors,
  COUNT(DISTINCT IF(event_name='investment_completed',profile_id,NULL)) AS investors,
  COUNT(DISTINCT IF(event_name='investment_completed' AND auto IS NOT TRUE,profile_id,NULL)) AS manual_investors,
  COUNT(DISTINCT IF(event_name='investment_completed' AND auto,profile_id,NULL)) AS auto_investors,
  COUNT(DISTINCT IF(event_name='investment_completed' AND first_inv,profile_id,NULL)) AS first_time_investors,
  COUNTIF(event_name='investment_completed') AS investments,
  COUNTIF(event_name='investment_completed' AND auto) AS auto_investments,
  SUM(IF(event_name='investment_completed' AND cur='SAR' AND auto IS NOT TRUE, amt, 0)) AS manual_inv_sar,
  COUNTIF(event_name='investment_completed' AND cur='SAR' AND auto IS NOT TRUE) AS manual_inv_sar_n,
  SUM(IF(event_name='investment_completed' AND cur='SAR' AND auto, amt, 0)) AS auto_inv_sar,
  COUNTIF(event_name='investment_completed' AND cur='SAR' AND auto) AS auto_inv_sar_n,
  COUNT(DISTINCT IF(event_name='auto_invest_enabled',profile_id,NULL)) AS auto_invest_enablers,
  COUNT(DISTINCT IF(event_name='withdrawal_completed',profile_id,NULL)) AS withdrawers
FROM e GROUP BY ROLLUP(p)
