-- ga4_traffic_daily: GA4 session-scoped (last-touch) acquisition per day (transfer).
-- READ-ONLY query (local mode). Run with execute_sql_readonly; use as a CTE/subquery and aggregate further.
-- Same logic as the future marketing_mart view of the same name (sql/marketing_mart/). Aggregated, no PII.
SELECT DATE(_PARTITIONTIME) AS report_date,
  LOWER(sessionSource) AS session_source, LOWER(sessionMedium) AS session_medium, sessionCampaignName AS session_campaign,
  sessionDefaultChannelGroup AS default_channel_group, sessionPrimaryChannelGroup AS primary_channel_group,
  sessions, engagedSessions AS engaged_sessions, keyEvents AS key_events, eventCount AS event_count
FROM `databases-472111.GA4.p_ga4_TrafficAcquisition_413046941`
