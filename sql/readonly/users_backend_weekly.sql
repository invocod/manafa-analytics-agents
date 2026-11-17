-- users_backend_weekly: weekly active backend users per platform and all (ISO weeks, Riyadh), last 8 weeks to the last complete day. Aggregated, no PII.
WITH b AS (SELECT DATE_SUB(MAX(DATE(occurred_at,'Asia/Riyadh')), INTERVAL 1 DAY) AS data_end FROM `databases-472111.manafa_financing.mi_analytics_events`),
e AS (
  SELECT DATE_TRUNC(DATE(occurred_at,'Asia/Riyadh'), ISOWEEK) AS wk, event_name, COALESCE(JSON_VALUE(context.platform),'unknown') AS p, profile_id, b.data_end
  FROM `databases-472111.manafa_financing.mi_analytics_events`, b
  WHERE DATE(occurred_at,'Asia/Riyadh') BETWEEN DATE_SUB(DATE_TRUNC(b.data_end, ISOWEEK), INTERVAL 7 WEEK) AND b.data_end AND profile_id IS NOT NULL)
SELECT wk, IF(GROUPING(p)=1,'all',p) AS platform, ANY_VALUE(data_end) AS data_end,
  COUNT(DISTINCT profile_id) AS active_users,
  COUNT(DISTINCT IF(event_name='login_completed',profile_id,NULL)) AS logged_in,
  COUNT(DISTINCT IF(event_name='investment_completed',profile_id,NULL)) AS investors
FROM e GROUP BY GROUPING SETS ((wk, p), (wk))
ORDER BY wk, platform
