-- gads_campaign_daily: Google Ads spend/traffic/claimed conversions per campaign per day.
-- READ-ONLY query (local mode). Run with execute_sql_readonly; use as a CTE/subquery and aggregate further.
-- Same logic as the future marketing_mart view of the same name (sql/marketing_mart/). Aggregated, no PII.
WITH names AS (
  SELECT campaign_id, campaign_name, campaign_status, campaign_advertising_channel_type AS channel_type
  FROM `databases-472111.google_ads.p_ads_Campaign_3343082801`
  QUALIFY ROW_NUMBER() OVER (PARTITION BY campaign_id ORDER BY _PARTITIONTIME DESC) = 1
)
SELECT s.segments_date AS report_date, s.campaign_id, n.campaign_name, n.campaign_status, n.channel_type,
  s.segments_device AS device, s.segments_ad_network_type AS network,
  SUM(s.metrics_cost_micros) / 1e6 AS cost, SUM(s.metrics_impressions) AS impressions, SUM(s.metrics_clicks) AS clicks,
  SUM(s.metrics_conversions) AS claimed_conversions, SUM(s.metrics_conversions_value) AS claimed_conversion_value
FROM `databases-472111.google_ads.p_ads_CampaignStats_3343082801` s
LEFT JOIN names n USING (campaign_id)
GROUP BY 1,2,3,4,5,6,7
