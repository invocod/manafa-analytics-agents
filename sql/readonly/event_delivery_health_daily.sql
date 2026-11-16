-- event_delivery_health_daily: Delivery status of backend events to GA4/Singular per Riyadh day. No PII.
-- READ-ONLY query (local mode). Run with execute_sql_readonly; use as a CTE/subquery and aggregate further.
-- Same logic as the future marketing_mart view of the same name (sql/marketing_mart/). Aggregated, no PII.
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
GROUP BY 1,2,3,4,5,6,7
