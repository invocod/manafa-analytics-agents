-- GA4 raw export (google_analytics.events_*), server-sent Manafa events only: each conversion is counted once by its
-- event_uuid param (copies without event_uuid are Singular/SDK duplicates, tqa-007). Platform = the event's platform param.
-- Aggregates only: event_uuid and the internal user_id param are used only inside COUNT/ROW_NUMBER, never output.
-- Data from 2026-11-04 (1-3 Nov are near-empty in the export). Newest day excluded downstream (late events).
WITH e AS (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS d, event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='event_uuid') AS uuid,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='platform') AS p,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='user_id') AS uid,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='currency') AS cur,
    (SELECT COALESCE(value.double_value, CAST(value.int_value AS FLOAT64)) FROM UNNEST(event_params) WHERE key='amount') AS amt,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key='is_first_investment') AS first_inv,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key='is_auto_invested') AS auto
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= '20261104' AND event_name IN ('login_completed','registration_completed','kyc_completed','deposit_success','withdrawal_completed','investment_completed','auto_invest_enabled')),
u AS (SELECT * FROM e WHERE uuid IS NOT NULL QUALIFY ROW_NUMBER() OVER (PARTITION BY event_name, uuid ORDER BY d) = 1),
b AS (SELECT DATE_SUB(MAX(d), INTERVAL 1 DAY) AS data_end FROM e),
w AS (SELECT u.*, b.data_end FROM u, b WHERE u.d BETWEEN GREATEST(DATE_SUB(b.data_end, INTERVAL 27 DAY), DATE '2026-11-04') AND b.data_end)
SELECT IF(GROUPING(p) = 1, 'all', p) AS platform, ANY_VALUE(data_end) AS data_end, MIN(d) AS from_d,
 COUNT(DISTINCT IF(event_name='login_completed', uid, NULL)) AS logged_in,
 COUNTIF(event_name='login_completed') AS logins,
 COUNTIF(event_name='registration_completed') AS registered,
 COUNTIF(event_name='kyc_completed') AS kyc_done,
 COUNT(DISTINCT IF(event_name='deposit_success', uid, NULL)) AS depositors,
 COUNT(DISTINCT IF(event_name='withdrawal_completed', uid, NULL)) AS withdrawers,
 COUNT(DISTINCT IF(event_name='investment_completed', uid, NULL)) AS investors,
 COUNT(DISTINCT IF(event_name='investment_completed' AND IFNULL(auto, 0) = 0, uid, NULL)) AS manual_investors,
 COUNT(DISTINCT IF(event_name='investment_completed' AND auto = 1, uid, NULL)) AS auto_investors,
 COUNTIF(event_name='investment_completed') AS investments,
 COUNTIF(event_name='investment_completed' AND auto = 1) AS auto_investments,
 COUNT(DISTINCT IF(event_name='investment_completed' AND first_inv = 1, uid, NULL)) AS first_time_investors,
 SUM(IF(event_name='investment_completed' AND IFNULL(auto, 0) = 0 AND cur='SAR', amt, 0)) AS manual_inv_sar,
 COUNTIF(event_name='investment_completed' AND IFNULL(auto, 0) = 0 AND cur='SAR') AS manual_inv_sar_n,
 SUM(IF(event_name='investment_completed' AND auto = 1 AND cur='SAR', amt, 0)) AS auto_inv_sar,
 COUNTIF(event_name='investment_completed' AND auto = 1 AND cur='SAR') AS auto_inv_sar_n,
 COUNT(DISTINCT IF(event_name='auto_invest_enabled', uid, NULL)) AS auto_invest_enablers
FROM w GROUP BY ROLLUP(p)
