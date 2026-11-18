-- ga4_events_daily: GA4 event counts per day, platform and event name.
-- Source: GA4 raw BigQuery export, dataset google_analytics (me-central2), daily tables events_YYYYMMDD only
--   (events_intraday_* excluded). Production streams: iOS 6313772845, Android 6314084012, Web 6314227817.
-- READ-ONLY, aggregated, no PII: user_pseudo_id / ga_session_id are used only inside COUNT(DISTINCT ...);
--   never select user_id, user_pseudo_id, user_properties, device ids, gclid or transaction ids.
-- Filter on _TABLE_SUFFIX (e.g. BETWEEN '20261109' AND '20261115') when you use it, so only the needed days are scanned.
SELECT PARSE_DATE('%Y%m%d', event_date) AS report_date,
  CASE platform WHEN 'IOS' THEN 'ios' WHEN 'ANDROID' THEN 'android' ELSE 'web' END AS platform,
  event_name, COUNT(*) AS event_count, COUNT(DISTINCT user_pseudo_id) AS total_users
FROM `databases-472111.google_analytics.events_*`
WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$')
GROUP BY 1, 2, 3
