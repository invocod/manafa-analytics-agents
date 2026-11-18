-- users_ga4_tech: Unique active users by device type, OS version, app version, device model and browser (last 7 days of data).
-- Source: GA4 raw BigQuery export, dataset google_analytics (me-central2), daily tables events_YYYYMMDD only
--   (events_intraday_* excluded). Production streams: iOS 6313772845, Android 6314084012, Web 6314227817.
-- READ-ONLY, aggregated, no PII: user_pseudo_id / ga_session_id are used only inside COUNT(DISTINCT ...);
--   never select user_id, user_pseudo_id, user_properties, device ids, gclid or transaction ids.
-- Filter on _TABLE_SUFFIX (e.g. BETWEEN '20261109' AND '20261115') when you use it, so only the needed days are scanned.
WITH e AS (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS d, CASE platform WHEN 'IOS' THEN 'iOS' WHEN 'ANDROID' THEN 'Android' ELSE 'web' END AS platform, user_pseudo_id AS u,
    device.category AS device_category,
    IF(STARTS_WITH(IFNULL(device.operating_system_version, ''), IFNULL(device.operating_system, '#')), device.operating_system_version, TRIM(CONCAT(IFNULL(device.operating_system, ''), ' ', IFNULL(device.operating_system_version, '')))) AS os_version,
    app_info.version AS app_version, device.web_info.browser AS browser,
    TRIM(CONCAT(IFNULL(device.mobile_brand_name, ''), ' ', IFNULL(device.mobile_marketing_name, device.mobile_model_name))) AS device_model
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE('Asia/Riyadh'), INTERVAL 30 DAY)) AND is_active_user),
de AS (SELECT MAX(d) AS d_end FROM e),
r AS (SELECT e.* FROM e, de WHERE e.d > DATE_SUB(de.d_end, INTERVAL 7 DAY)),
l AS (
  SELECT 'device_category' AS dim, platform, device_category AS v, COUNT(DISTINCT u) AS users FROM r GROUP BY 1, 2, 3
  UNION ALL SELECT 'os_version', platform, os_version, COUNT(DISTINCT u) FROM r GROUP BY 1, 2, 3
  UNION ALL SELECT 'app_version', platform, app_version, COUNT(DISTINCT u) FROM r WHERE platform != 'web' GROUP BY 1, 2, 3
  UNION ALL SELECT 'device_model', platform, device_model, COUNT(DISTINCT u) FROM r WHERE platform != 'web' GROUP BY 1, 2, 3
  UNION ALL SELECT 'browser', platform, browser, COUNT(DISTINCT u) FROM r WHERE platform = 'web' GROUP BY 1, 2, 3)
SELECT dim, platform, IFNULL(NULLIF(v, ''), '(not set)') AS v, users, (SELECT MIN(d) FROM r) AS from_d, (SELECT MAX(d) FROM r) AS to_d FROM l
QUALIFY ROW_NUMBER() OVER (PARTITION BY dim, platform ORDER BY users DESC) <= 12
ORDER BY dim, platform, users DESC
