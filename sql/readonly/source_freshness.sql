-- source_freshness: Latest available date per marketing source; loops halt if stale.
-- READ-ONLY query (local mode). Run with execute_sql_readonly. Aggregated, no PII.
-- GA4 = raw export dataset google_analytics (latest complete daily table); the old GA4 transfer dataset is retired (2026-11-18).
SELECT 'backend_events' AS source, MAX(DATE(occurred_at, 'Asia/Riyadh')) AS latest_date FROM `databases-472111.manafa_financing.mi_analytics_events`
UNION ALL SELECT 'investor_journey', DATE(MAX(dwh_built_at)) FROM `databases-472111.gold.fact_investor_journey`
UNION ALL SELECT 'ga4', MAX(PARSE_DATE('%Y%m%d', _TABLE_SUFFIX)) FROM `databases-472111.google_analytics.events_*` WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$')
UNION ALL SELECT 'google_ads', MAX(segments_date) FROM `databases-472111.google_ads.p_ads_CampaignStats_3343082801`
