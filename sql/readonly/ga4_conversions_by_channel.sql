-- ga4_conversions_by_channel: GA4 server-sent conversions per ISO week by GA4 session channel (last touch)
-- and first-user source / medium (first touch). Used by bi-channel-attribution and bi-paid-media-review
-- (GA4 section only; labelled GA4; never blended with backend or Google Ads numbers).
-- Source: raw GA4 export google_analytics.events_* (production streams), daily tables only, from 2026-11-04.
-- One conversion per event_uuid (copies without event_uuid are app-stream duplicates, tqa-007).
-- GA4 misses events the backend couldn't deliver (tqa-013): these counts are a floor (see ga4_backend_coverage.sql).
-- Aggregates only; event_uuid is used only for de-duplication.
WITH e AS (
  SELECT DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), ISOWEEK) AS wk, event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='event_uuid') AS uuid,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key='platform') AS platform,
    IFNULL(session_traffic_source_last_click.cross_channel_campaign.default_channel_group, 'Unassigned') AS lt_channel,
    IFNULL(session_traffic_source_last_click.cross_channel_campaign.campaign_name, '(not set)') AS lt_campaign,
    LOWER(CONCAT(IFNULL(traffic_source.source, '(direct)'), ' / ', IFNULL(traffic_source.medium, '(none)'))) AS ft_source_medium,
    IFNULL(traffic_source.name, '(not set)') AS ft_campaign
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= '20261104'
    AND event_name IN ('registration_completed', 'deposit_success', 'investment_completed')),
u AS (SELECT * FROM e WHERE uuid IS NOT NULL QUALIFY ROW_NUMBER() OVER (PARTITION BY event_name, uuid ORDER BY wk) = 1)
SELECT wk, event_name, platform, lt_channel, lt_campaign, ft_source_medium, ft_campaign, COUNT(*) AS conversions
FROM u
GROUP BY 1, 2, 3, 4, 5, 6, 7
ORDER BY wk, event_name, conversions DESC
