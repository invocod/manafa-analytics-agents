-- Run-start freshness gate for every loop: latest date per source vs today (Riyadh).
CREATE OR REPLACE VIEW `databases-472111.marketing_mart.source_freshness`
OPTIONS (description = 'Latest available date per marketing source; loops halt if stale.') AS
SELECT 'backend_events' AS source, MAX(DATE(occurred_at, 'Asia/Riyadh')) AS latest_date FROM `databases-472111.manafa_financing.mi_analytics_events`
UNION ALL SELECT 'investor_journey', DATE(MAX(dwh_built_at)) FROM `databases-472111.gold.fact_investor_journey`
UNION ALL SELECT 'ga4', MAX(DATE(_PARTITIONTIME)) FROM `databases-472111.GA4.p_ga4_Events_413046941`
UNION ALL SELECT 'google_ads', MAX(segments_date) FROM `databases-472111.google_ads.p_ads_CampaignStats_3343082801`;
