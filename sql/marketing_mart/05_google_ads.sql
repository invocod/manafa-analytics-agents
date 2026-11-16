-- Google Ads (customer 3343082801) Data Transfer. Cost converted from micros (account currency).
CREATE OR REPLACE VIEW `databases-472111.marketing_mart.gads_campaign_daily`
OPTIONS (description = 'Google Ads spend/traffic/claimed conversions per campaign per day.') AS
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
GROUP BY 1,2,3,4,5,6,7;

CREATE OR REPLACE VIEW `databases-472111.marketing_mart.gads_conversions_daily`
OPTIONS (description = 'Google Ads claimed conversions per campaign x conversion action per day.') AS
SELECT segments_date AS report_date, campaign_id, segments_conversion_action_name AS conversion_action,
  segments_conversion_action_category AS conversion_category, segments_conversion_attribution_event_type AS attribution_event_type,
  SUM(metrics_conversions) AS claimed_conversions, SUM(metrics_conversions_value) AS claimed_conversion_value
FROM `databases-472111.google_ads.p_ads_CampaignConversionStats_3343082801`
GROUP BY 1,2,3,4,5;
