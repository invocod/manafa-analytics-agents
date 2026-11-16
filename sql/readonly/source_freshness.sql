-- source_freshness: Latest available date per marketing source; loops halt if stale.
-- READ-ONLY query (local mode). Run with execute_sql_readonly; use as a CTE/subquery and aggregate further.
-- Same logic as the future marketing_mart view of the same name (sql/marketing_mart/). Aggregated, no PII.
SELECT 'backend_events' AS source, MAX(DATE(occurred_at, 'Asia/Riyadh')) AS latest_date FROM `databases-472111.manafa_financing.mi_analytics_events`
UNION ALL SELECT 'investor_journey', DATE(MAX(dwh_built_at)) FROM `databases-472111.gold.fact_investor_journey`
UNION ALL SELECT 'ga4', MAX(DATE(_PARTITIONTIME)) FROM `databases-472111.GA4.p_ga4_Events_413046941`
UNION ALL SELECT 'google_ads', MAX(segments_date) FROM `databases-472111.google_ads.p_ads_CampaignStats_3343082801`
