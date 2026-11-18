-- GA4 views over the raw GA4 BigQuery export (dataset google_analytics, me-central2; production copy of
-- property "Manafa Mobile & Web Apps", streams iOS 6313772845, Android 6314084012, Web 6314227817).
-- Replaces the retired GA4 Data Transfer tables (GA4.p_ga4_*_413046941), which inflated sessions and
-- mislabelled app screens (see tqa-001, tqa-021, 2026-11-18).
-- Daily tables only (events_YYYYMMDD); events_intraday_* excluded. Aggregates only, no PII:
-- user_pseudo_id / ga_session_id appear only inside COUNT(DISTINCT ...); user_properties are never read.
-- Same logic as sql/readonly/ga4_*.sql. Filter on report_date when querying these views.

CREATE OR REPLACE VIEW `databases-472111.marketing_mart.ga4_events_daily`
OPTIONS (description = 'GA4 event counts per day, platform and event (raw export, production streams).') AS
SELECT PARSE_DATE('%Y%m%d', event_date) AS report_date,
  CASE platform WHEN 'IOS' THEN 'ios' WHEN 'ANDROID' THEN 'android' ELSE 'web' END AS platform,
  event_name, COUNT(*) AS event_count, COUNT(DISTINCT user_pseudo_id) AS total_users
FROM `databases-472111.google_analytics.events_*`
WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$')
GROUP BY 1, 2, 3;

CREATE OR REPLACE VIEW `databases-472111.marketing_mart.ga4_traffic_daily`
OPTIONS (description = 'GA4 sessions per day by session (last-click) source/medium/campaign/channel (raw export).') AS
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
FROM s GROUP BY 1, 2, 3, 4, 5, 6, 7;

CREATE OR REPLACE VIEW `databases-472111.marketing_mart.ga4_user_acquisition_daily`
OPTIONS (description = 'GA4 new users per day by first-user source/medium/campaign (raw export).') AS
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
FROM f GROUP BY 1, 2, 3, 4, 5, 6;
