-- users_ga4_demographics: Unique active users by country, region, city and device language (last 7 days of data). Age, gender and interests are not in the raw export.
-- Source: GA4 raw BigQuery export, dataset google_analytics (me-central2), daily tables events_YYYYMMDD only
--   (events_intraday_* excluded). Production streams: iOS 6313772845, Android 6314084012, Web 6314227817.
-- READ-ONLY, aggregated, no PII: user_pseudo_id / ga_session_id are used only inside COUNT(DISTINCT ...);
--   never select user_id, user_pseudo_id, user_properties, device ids, gclid or transaction ids.
-- Filter on _TABLE_SUFFIX (e.g. BETWEEN '20261109' AND '20261115') when you use it, so only the needed days are scanned.
WITH e AS (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS d, user_pseudo_id AS u, geo.country AS country, geo.region AS region, geo.city AS city,
    LOWER(SPLIT(device.language, '-')[SAFE_OFFSET(0)]) AS language
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE('Asia/Riyadh'), INTERVAL 30 DAY)) AND is_active_user),
de AS (SELECT MAX(d) AS d_end FROM e),
r AS (SELECT e.* FROM e, de WHERE e.d > DATE_SUB(de.d_end, INTERVAL 7 DAY)),
l AS (
  SELECT 'country' AS dim, country AS v, COUNT(DISTINCT u) AS users FROM r GROUP BY 1, 2
  UNION ALL SELECT 'region', region, COUNT(DISTINCT u) FROM r GROUP BY 1, 2
  UNION ALL SELECT 'city', city, COUNT(DISTINCT u) FROM r GROUP BY 1, 2
  UNION ALL SELECT 'language', language, COUNT(DISTINCT u) FROM r GROUP BY 1, 2)
SELECT dim, IFNULL(NULLIF(v, ''), '(not set)') AS v, users, (SELECT MIN(d) FROM r) AS from_d, (SELECT MAX(d) FROM r) AS to_d FROM l
QUALIFY ROW_NUMBER() OVER (PARTITION BY dim ORDER BY users DESC) <= 12
ORDER BY dim, users DESC
