-- GA4 raw export (google_analytics.events_*), server-sent Manafa events only: each conversion is counted once by its
-- event_uuid param (copies without event_uuid are Singular/SDK duplicates, tqa-007). Platform = the event's platform param.
-- Aggregates only: event_uuid and the internal user_id param are used only inside COUNT/ROW_NUMBER, never output.
-- Data from 2026-11-04 (1-3 Nov are near-empty in the export). Newest day excluded downstream (late events).
WITH e AS (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS d, event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='event_uuid') AS uuid,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='platform') AS p,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='currency') AS cur,
    (SELECT COALESCE(value.double_value, CAST(value.int_value AS FLOAT64)) FROM UNNEST(event_params) WHERE key='amount') AS amt,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key='is_first_investment') AS first_inv
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= '20261104' AND event_name IN ('registration_completed','kyc_completed','identity_verified','deposit_success','investment_completed','auto_invest_enabled')),
u AS (SELECT * FROM e WHERE uuid IS NOT NULL QUALIFY ROW_NUMBER() OVER (PARTITION BY event_name, uuid ORDER BY d) = 1)
SELECT d,
 COUNTIF(event_name='registration_completed') AS reg,
 COUNTIF(event_name='registration_completed' AND p='web') AS reg_web,
 COUNTIF(event_name='registration_completed' AND p='ios') AS reg_ios,
 COUNTIF(event_name='registration_completed' AND p='android') AS reg_android,
 COUNTIF(event_name='kyc_completed') AS kyc,
 COUNTIF(event_name='identity_verified') AS idv,
 COUNTIF(event_name='deposit_success') AS dep,
 SUM(IF(event_name='deposit_success' AND cur='SAR', amt, 0)) AS dep_sar,
 SUM(IF(event_name='deposit_success' AND cur='USD', amt, 0)) AS dep_usd,
 COUNTIF(event_name='investment_completed') AS inv,
 SUM(IF(event_name='investment_completed' AND cur='SAR', amt, 0)) AS inv_sar,
 COUNTIF(event_name='investment_completed' AND first_inv=1) AS first_inv,
 COUNTIF(event_name='auto_invest_enabled') AS ai_on
FROM u GROUP BY 1 ORDER BY 1
