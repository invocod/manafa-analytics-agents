-- ga4_user_acquisition_daily: GA4 new users per day by first-user source / medium / campaign (first touch).
-- Source: GA4 raw BigQuery export, dataset google_analytics (me-central2), daily tables events_YYYYMMDD only
--   (events_intraday_* excluded). Production streams: iOS 6313772845, Android 6314084012, Web 6314227817.
-- READ-ONLY, aggregated, no PII: user_pseudo_id / ga_session_id are used only inside COUNT(DISTINCT ...);
--   never select user_id, user_pseudo_id, user_properties, device ids, gclid or transaction ids.
-- Filter on _TABLE_SUFFIX (e.g. BETWEEN '20261109' AND '20261115') when you use it, so only the needed days are scanned.
-- New user = a user_pseudo_id with first_open (apps) or first_visit (web) that day.
-- first-user source/medium/campaign = traffic_source.* ; channel = GA4 default channel group of that first session.
WITH f AS (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS d, platform, user_pseudo_id AS u,
    traffic_source.source AS src, traffic_source.medium AS med, traffic_source.name AS camp,
    session_traffic_source_last_click.cross_channel_campaign.default_channel_group AS ch
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND event_name IN ('first_open', 'first_visit'))
SELECT d AS report_date,
  CASE platform WHEN 'IOS' THEN 'ios' WHEN 'ANDROID' THEN 'android' ELSE 'web' END AS platform,
  LOWER(IFNULL(src, '(direct)')) AS first_user_source, LOWER(IFNULL(med, '(none)')) AS first_user_medium,
  IFNULL(camp, '(not set)') AS first_user_campaign, IFNULL(ch, 'Unassigned') AS default_channel_group,
  COUNT(DISTINCT u) AS new_users
FROM f GROUP BY 1, 2, 3, 4, 5, 6
