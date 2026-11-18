-- GA4 raw export (google_analytics.events_*), server-sent Manafa events only: each conversion is counted once by its
-- event_uuid param (copies without event_uuid are Singular/SDK duplicates, tqa-007). Platform = the event's platform param.
-- Aggregates only: event_uuid and the internal user_id param are used only inside COUNT/ROW_NUMBER, never output.
-- Data from 2026-11-04 (1-3 Nov are near-empty in the export). Newest day excluded downstream (late events).
WITH e AS (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS d, event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='event_uuid') AS uuid,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='platform') AS p,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='user_id') AS uid
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= '20261104' AND event_name IN ('registration_completed','kyc_completed','deposit_success','investment_completed')),
u AS (SELECT * FROM e WHERE uuid IS NOT NULL QUALIFY ROW_NUMBER() OVER (PARTITION BY event_name, uuid ORDER BY d) = 1),
de AS (SELECT DATE_SUB(MAX(d), INTERVAL 1 DAY) AS d_end FROM e),
reg AS (SELECT uid, MIN(d) AS reg_date, ARRAY_AGG(p IGNORE NULLS ORDER BY d LIMIT 1)[SAFE_OFFSET(0)] AS p FROM u WHERE event_name='registration_completed' AND uid IS NOT NULL GROUP BY 1),
f AS (SELECT uid, MIN(IF(event_name='kyc_completed',d,NULL)) AS kyc, MIN(IF(event_name='deposit_success',d,NULL)) AS dep, MIN(IF(event_name='investment_completed',d,NULL)) AS inv FROM u WHERE uid IS NOT NULL GROUP BY 1)
SELECT DATE_TRUNC(r.reg_date, ISOWEEK) AS cohort_week, r.p AS platform,
 DATE_DIFF((SELECT d_end FROM de), DATE_TRUNC(r.reg_date, ISOWEEK), DAY) AS age,
 COUNT(*) AS n,
 COUNTIF(DATE_DIFF(f.kyc, r.reg_date, DAY) BETWEEN 0 AND 14) AS kyc14,
 COUNTIF(DATE_DIFF(f.dep, r.reg_date, DAY) BETWEEN 0 AND 14) AS dep14,
 COUNTIF(DATE_DIFF(f.inv, r.reg_date, DAY) BETWEEN 0 AND 14) AS inv14
FROM reg r LEFT JOIN f USING (uid)
WHERE r.reg_date <= (SELECT d_end FROM de)
GROUP BY 1, 2, 3 ORDER BY 1
