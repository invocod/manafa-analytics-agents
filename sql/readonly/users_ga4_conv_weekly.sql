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
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= '20261104' AND event_name IN ('login_completed')),
u AS (SELECT * FROM e WHERE uuid IS NOT NULL QUALIFY ROW_NUMBER() OVER (PARTITION BY event_name, uuid ORDER BY d) = 1),
b AS (SELECT DATE_SUB(MAX(d), INTERVAL 1 DAY) AS data_end FROM e)
SELECT DATE_TRUNC(u.d, ISOWEEK) AS wk, u.p AS platform, COUNT(DISTINCT u.uid) AS logged_in, ANY_VALUE(b.data_end) AS data_end
FROM u, b WHERE u.d <= b.data_end AND u.p IS NOT NULL
GROUP BY 1, 2 ORDER BY 1
