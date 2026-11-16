-- gads_conversions_daily: Google Ads claimed conversions per campaign x conversion action per day.
-- READ-ONLY query (local mode). Run with execute_sql_readonly; use as a CTE/subquery and aggregate further.
-- Same logic as the future marketing_mart view of the same name (sql/marketing_mart/). Aggregated, no PII.
SELECT segments_date AS report_date, campaign_id, segments_conversion_action_name AS conversion_action,
  segments_conversion_action_category AS conversion_category, segments_conversion_attribution_event_type AS attribution_event_type,
  SUM(metrics_conversions) AS claimed_conversions, SUM(metrics_conversions_value) AS claimed_conversion_value
FROM `databases-472111.google_ads.p_ads_CampaignConversionStats_3343082801`
GROUP BY 1,2,3,4,5
