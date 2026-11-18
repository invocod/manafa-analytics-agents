-- users_ga4_week: GA4 unique users, new users, sessions and engagement over the last 7 days of data, per platform and in total.
-- Source: GA4 raw BigQuery export, dataset google_analytics (me-central2), daily tables events_YYYYMMDD only
--   (events_intraday_* excluded). Production streams: iOS 6313772845, Android 6314084012, Web 6314227817.
-- READ-ONLY, aggregated, no PII: user_pseudo_id / ga_session_id are used only inside COUNT(DISTINCT ...);
--   never select user_id, user_pseudo_id, user_properties, device ids, gclid or transaction ids.
-- Filter on _TABLE_SUFFIX (e.g. BETWEEN '20261109' AND '20261115') when you use it, so only the needed days are scanned.
WITH e AS (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS d, CASE platform WHEN 'IOS' THEN 'iOS' WHEN 'ANDROID' THEN 'Android' ELSE 'web' END AS p, user_pseudo_id AS u, is_active_user, event_name,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key='ga_session_id') AS sid, (SELECT COALESCE(value.string_value, CAST(value.int_value AS STRING)) FROM UNNEST(event_params) WHERE key='session_engaged') AS eng, (SELECT value.int_value FROM UNNEST(event_params) WHERE key='engagement_time_msec') AS etm
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE('Asia/Riyadh'), INTERVAL 45 DAY))),
de AS (SELECT MAX(d) AS d_end FROM e),
w AS (SELECT e.* FROM e, de WHERE e.d > DATE_SUB(de.d_end, INTERVAL 7 DAY))
SELECT IF(GROUPING(p) = 1, 'all', p) AS platform,
  COUNT(DISTINCT IF(is_active_user, u, NULL)) AS active_users,
  COUNT(DISTINCT IF(event_name IN ('first_open','first_visit'), u, NULL)) AS new_users,
  COUNT(DISTINCT IF(sid IS NOT NULL, CONCAT(u, '-', CAST(sid AS STRING)), NULL)) AS sessions,
  COUNT(DISTINCT IF(sid IS NOT NULL AND eng = '1', CONCAT(u, '-', CAST(sid AS STRING)), NULL)) AS engaged_sessions,
  COUNT(*) AS events, ROUND(SUM(IFNULL(etm, 0)) / 1000) AS engagement_sec,
  MIN(d) AS from_d, MAX(d) AS to_d
FROM w GROUP BY ROLLUP(p) ORDER BY platform
