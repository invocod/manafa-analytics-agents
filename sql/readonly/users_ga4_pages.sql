-- users_ga4_pages: GA4 top web pages and app screens, last 7 days in the transfer. Long digit runs masked as <ID> (tqa-005). Aggregated.
WITH r AS (SELECT *, DATE(_PARTITIONTIME) AS pd FROM `databases-472111.GA4.p_ga4_PagesAndScreens_413046941`
  WHERE DATE(_PARTITIONTIME) >= DATE_SUB((SELECT MAX(DATE(_PARTITIONTIME)) FROM `databases-472111.GA4.p_ga4_PagesAndScreens_413046941`), INTERVAL 6 DAY)),
l AS (
  SELECT IF(STARTS_WITH(unifiedPagePathScreen,'/'),'web','app') AS kind,
    REGEXP_REPLACE(REGEXP_REPLACE(unifiedPagePathScreen, r'\d{5,}', '<ID>'), r'[?#].*$', '') AS page,
    SUM(screenPageViews) AS views, SUM(activeUsers) AS users, SUM(userEngagementDuration) AS engagement_sec
  FROM r GROUP BY 1, 2)
SELECT kind, page, views, users, engagement_sec, (SELECT MIN(pd) FROM r) AS from_d, (SELECT MAX(pd) FROM r) AS to_d FROM l
QUALIFY ROW_NUMBER() OVER (PARTITION BY kind ORDER BY views DESC) <= 20
ORDER BY kind, views DESC
