-- users_ga4_demographics: GA4 demographics (Google signals estimates, thresholded), last 7 days in the transfer, all platforms. users = summed daily active users; use shares only.
WITH r AS (SELECT *, DATE(_PARTITIONTIME) AS pd FROM `databases-472111.GA4.p_ga4_DemographicDetails_413046941`
  WHERE DATE(_PARTITIONTIME) >= DATE_SUB((SELECT MAX(DATE(_PARTITIONTIME)) FROM `databases-472111.GA4.p_ga4_DemographicDetails_413046941`), INTERVAL 6 DAY)),
l AS (
  SELECT 'age' AS dim, userAgeBracket AS v, SUM(activeUsers) AS users FROM r GROUP BY 1,2
  UNION ALL SELECT 'gender', userGender, SUM(activeUsers) FROM r GROUP BY 1,2
  UNION ALL SELECT 'country', country, SUM(activeUsers) FROM r GROUP BY 1,2
  UNION ALL SELECT 'region', region, SUM(activeUsers) FROM r GROUP BY 1,2
  UNION ALL SELECT 'city', city, SUM(activeUsers) FROM r GROUP BY 1,2
  UNION ALL SELECT 'language', language, SUM(activeUsers) FROM r GROUP BY 1,2
  UNION ALL SELECT 'interest', brandingInterest, SUM(activeUsers) FROM r GROUP BY 1,2)
SELECT dim, v, users, (SELECT MIN(pd) FROM r) AS from_d, (SELECT MAX(pd) FROM r) AS to_d FROM l
QUALIFY ROW_NUMBER() OVER (PARTITION BY dim ORDER BY users DESC) <= 12
ORDER BY dim, users DESC
