-- users_ga4_daily: GA4 activity per day and platform (transfer TechDetails), last 14 days in the transfer. Daily active users are summed per day; a week figure is an average per day, not unique users.
SELECT DATE(_PARTITIONTIME) AS d, platform,
  SUM(activeUsers) AS active_users, SUM(newUsers) AS new_users, SUM(engagedSessions) AS engaged_sessions,
  SUM(eventCount) AS events, SUM(userEngagementDuration) AS engagement_sec
FROM `databases-472111.GA4.p_ga4_TechDetails_413046941`
WHERE DATE(_PARTITIONTIME) >= DATE_SUB((SELECT MAX(DATE(_PARTITIONTIME)) FROM `databases-472111.GA4.p_ga4_TechDetails_413046941`), INTERVAL 13 DAY)
GROUP BY 1, 2 ORDER BY 1, 2
