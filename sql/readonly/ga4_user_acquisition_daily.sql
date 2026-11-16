-- ga4_user_acquisition_daily: GA4 first-user (first-touch) acquisition per day (transfer).
-- READ-ONLY query (local mode). Run with execute_sql_readonly; use as a CTE/subquery and aggregate further.
-- Same logic as the future marketing_mart view of the same name (sql/marketing_mart/). Aggregated, no PII.
SELECT DATE(_PARTITIONTIME) AS report_date,
  LOWER(firstUserSource) AS first_user_source, LOWER(firstUserMedium) AS first_user_medium, firstUserCampaignName AS first_user_campaign,
  firstUserDefaultChannelGroup AS default_channel_group,
  newUsers AS new_users, activeUsers AS active_users, keyEvents AS key_events
FROM `databases-472111.GA4.p_ga4_UserAcquisition_413046941`
