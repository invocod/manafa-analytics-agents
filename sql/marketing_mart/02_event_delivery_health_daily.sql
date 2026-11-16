-- Backend -> vendor delivery health (GA4, Singular). Tracking-QA input. No error payloads exposed.
CREATE OR REPLACE VIEW `databases-472111.marketing_mart.event_delivery_health_daily`
OPTIONS (description = 'Delivery status of backend events to GA4/Singular per Riyadh day. No PII.') AS
SELECT
  DATE(e.occurred_at, 'Asia/Riyadh') AS event_date,
  e.event_name,
  JSON_VALUE(e.context.platform)     AS platform,
  d.channel,
  d.status,
  d.attribution_scope,
  d.degraded_reason,
  COUNT(*)                           AS deliveries,
  AVG(d.attempts)                    AS avg_attempts
FROM `databases-472111.manafa_financing.mi_analytics_event_deliveries` d
JOIN `databases-472111.manafa_financing.mi_analytics_events` e
  ON e.id = d.analytics_event_id
GROUP BY 1,2,3,4,5,6,7;
