-- users_ga4_tech: GA4 tech mix over the last 7 days in the transfer. users = summed daily active users (user-days); use shares. Top 12 per dimension and platform.
WITH r AS (SELECT *, DATE(_PARTITIONTIME) AS pd FROM `databases-472111.GA4.p_ga4_TechDetails_413046941`
  WHERE DATE(_PARTITIONTIME) >= DATE_SUB((SELECT MAX(DATE(_PARTITIONTIME)) FROM `databases-472111.GA4.p_ga4_TechDetails_413046941`), INTERVAL 6 DAY)),
l AS (
  SELECT 'device_category' AS dim, platform, deviceCategory AS v, SUM(activeUsers) AS users FROM r GROUP BY 1,2,3
  UNION ALL SELECT 'os_version', platform, operatingSystemWithVersion, SUM(activeUsers) FROM r GROUP BY 1,2,3
  UNION ALL SELECT 'app_version', platform, appVersion, SUM(activeUsers) FROM r WHERE platform!='web' GROUP BY 1,2,3
  UNION ALL SELECT 'browser', platform, browser, SUM(activeUsers) FROM r WHERE platform='web' GROUP BY 1,2,3
  UNION ALL SELECT 'screen', platform, screenResolution, SUM(activeUsers) FROM r WHERE platform='web' GROUP BY 1,2,3)
SELECT dim, platform, v, users, (SELECT MIN(pd) FROM r) AS from_d, (SELECT MAX(pd) FROM r) AS to_d FROM l
QUALIFY ROW_NUMBER() OVER (PARTITION BY dim, platform ORDER BY users DESC) <= 12
ORDER BY dim, platform, users DESC
