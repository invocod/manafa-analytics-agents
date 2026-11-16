-- ga4_events_daily: GA4 event counts per day (transfer). All streams incl. QA.
-- READ-ONLY query (local mode). Run with execute_sql_readonly; use as a CTE/subquery and aggregate further.
-- Same logic as the future marketing_mart view of the same name (sql/marketing_mart/). Aggregated, no PII.
SELECT DATE(_PARTITIONTIME) AS report_date, eventName AS event_name, eventCount AS event_count, totalUsers AS total_users
FROM `databases-472111.GA4.p_ga4_Events_413046941`
