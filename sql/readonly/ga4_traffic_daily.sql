-- ga4_traffic_daily: GA4 sessions per day by session (last-click) source / medium / campaign and GA4 default channel group.
-- Source: GA4 raw BigQuery export, dataset google_analytics (me-central2), daily tables events_YYYYMMDD only
--   (events_intraday_* excluded). Production streams: iOS 6313772845, Android 6314084012, Web 6314227817.
-- READ-ONLY, aggregated, no PII: user_pseudo_id / ga_session_id are used only inside COUNT(DISTINCT ...);
--   never select user_id, user_pseudo_id, user_properties, device ids, gclid or transaction ids.
-- Filter on _TABLE_SUFFIX (e.g. BETWEEN '20261109' AND '20261115') when you use it, so only the needed days are scanned.
-- A session = user_pseudo_id + ga_session_id. Channel = session_traffic_source_last_click.cross_channel_campaign
-- (GA4's own session attribution). Sessions with no attributed source are 'Unassigned'.
WITH e AS (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS d, platform, user_pseudo_id AS u, event_name,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS sid,
    (SELECT COALESCE(value.string_value, CAST(value.int_value AS STRING)) FROM UNNEST(event_params) WHERE key = 'session_engaged') AS eng,
    session_traffic_source_last_click.cross_channel_campaign AS c
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$')),
s AS (
  SELECT CONCAT(u, '-', CAST(sid AS STRING)) AS k, MIN(d) AS d, ANY_VALUE(platform) AS platform,
    LOGICAL_OR(eng = '1') AS engaged, COUNT(*) AS events,
    ARRAY_AGG(c IGNORE NULLS ORDER BY c.default_channel_group IS NULL LIMIT 1)[SAFE_OFFSET(0)] AS c
  FROM e WHERE sid IS NOT NULL GROUP BY 1)
SELECT d AS report_date,
  CASE platform WHEN 'IOS' THEN 'ios' WHEN 'ANDROID' THEN 'android' ELSE 'web' END AS platform,
  LOWER(IFNULL(c.source, '(direct)')) AS session_source, LOWER(IFNULL(c.medium, '(none)')) AS session_medium,
  IFNULL(c.campaign_name, '(not set)') AS session_campaign,
  IFNULL(c.default_channel_group, 'Unassigned') AS default_channel_group,
  IFNULL(c.primary_channel_group, 'Unassigned') AS primary_channel_group,
  COUNT(*) AS sessions, COUNTIF(engaged) AS engaged_sessions, SUM(events) AS event_count
FROM s GROUP BY 1, 2, 3, 4, 5, 6, 7
