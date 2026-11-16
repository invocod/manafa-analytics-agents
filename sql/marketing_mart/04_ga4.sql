-- GA4 (property 413046941) Data Transfer tables, exposed per report date. Already aggregated by Google.
-- NOTE: transfer tables carry no stream/platform column, so QA streams cannot be excluded here.
-- Production-only reporting needs the raw GA4 export (analytics_413046941) in me-central2 (Phase 2).
CREATE OR REPLACE VIEW `databases-472111.marketing_mart.ga4_events_daily`
OPTIONS (description = 'GA4 event counts per day (transfer). All streams incl. QA.') AS
SELECT DATE(_PARTITIONTIME) AS report_date, eventName AS event_name, eventCount AS event_count, totalUsers AS total_users
FROM `databases-472111.GA4.p_ga4_Events_413046941`;

CREATE OR REPLACE VIEW `databases-472111.marketing_mart.ga4_traffic_daily`
OPTIONS (description = 'GA4 session-scoped (last-touch) acquisition per day (transfer).') AS
SELECT DATE(_PARTITIONTIME) AS report_date,
  LOWER(sessionSource) AS session_source, LOWER(sessionMedium) AS session_medium, sessionCampaignName AS session_campaign,
  sessionDefaultChannelGroup AS default_channel_group, sessionPrimaryChannelGroup AS primary_channel_group,
  sessions, engagedSessions AS engaged_sessions, keyEvents AS key_events, eventCount AS event_count
FROM `databases-472111.GA4.p_ga4_TrafficAcquisition_413046941`;

CREATE OR REPLACE VIEW `databases-472111.marketing_mart.ga4_user_acquisition_daily`
OPTIONS (description = 'GA4 first-user (first-touch) acquisition per day (transfer).') AS
SELECT DATE(_PARTITIONTIME) AS report_date,
  LOWER(firstUserSource) AS first_user_source, LOWER(firstUserMedium) AS first_user_medium, firstUserCampaignName AS first_user_campaign,
  firstUserDefaultChannelGroup AS default_channel_group,
  newUsers AS new_users, activeUsers AS active_users, keyEvents AS key_events
FROM `databases-472111.GA4.p_ga4_UserAcquisition_413046941`;
