-- users_ga4_pages: Top web pages (page_view, IDs masked) and app screens (screen_view firebase_screen) with views, unique users and engagement time (last 7 days of data).
-- Source: GA4 raw BigQuery export, dataset google_analytics (me-central2), daily tables events_YYYYMMDD only
--   (events_intraday_* excluded). Production streams: iOS 6313772845, Android 6314084012, Web 6314227817.
-- READ-ONLY, aggregated, no PII: user_pseudo_id / ga_session_id are used only inside COUNT(DISTINCT ...);
--   never select user_id, user_pseudo_id, user_properties, device ids, gclid or transaction ids.
-- Filter on _TABLE_SUFFIX (e.g. BETWEEN '20261109' AND '20261115') when you use it, so only the needed days are scanned.
WITH e AS (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS d, platform, user_pseudo_id AS u, event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='page_location') AS loc, (SELECT value.string_value FROM UNNEST(event_params) WHERE key='firebase_screen') AS scr, (SELECT value.string_value FROM UNNEST(event_params) WHERE key='firebase_screen_class') AS scls,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key='engagement_time_msec') AS etm
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE('Asia/Riyadh'), INTERVAL 30 DAY)) AND event_name IN ('page_view', 'screen_view', 'user_engagement')),
de AS (SELECT MAX(d) AS d_end FROM e),
r AS (SELECT IF(platform = 'WEB', 'web', 'app') AS kind,
    IF(platform = 'WEB',
       REGEXP_REPLACE(IFNULL(REGEXP_EXTRACT(loc, r'^https?://[^/?#]+(/[^?#]*)'), '/'), r'[A-Za-z]{0,6}\d{5,}', '<ID>'),
       REGEXP_REPLACE(COALESCE(scr, scls, '(not set)'), r'\d{5,}', '<ID>')) AS page,
    event_name, u, etm, d
  FROM e, de WHERE e.d > DATE_SUB(de.d_end, INTERVAL 7 DAY)),
l AS (SELECT kind, page, COUNTIF(event_name IN ('page_view', 'screen_view')) AS views,
    COUNT(DISTINCT IF(event_name IN ('page_view', 'screen_view'), u, NULL)) AS users,
    ROUND(SUM(IFNULL(etm, 0)) / 1000) AS engagement_sec
  FROM r GROUP BY 1, 2)
SELECT kind, page, views, users, engagement_sec, (SELECT MIN(d) FROM r) AS from_d, (SELECT MAX(d) FROM r) AS to_d FROM l
WHERE views > 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY kind ORDER BY views DESC) <= 20
ORDER BY kind, views DESC
