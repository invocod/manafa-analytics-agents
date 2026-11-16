-- investor_funnel_cohorts_prod: registration cohorts (ISO week, Riyadh) from PRODUCTION backend events.
-- Replaces gold-based cohorts (gold suspended, tqa-012). Aggregated, no PII; profile_id used only inside the query.
-- Steps = first occurrence per profile. Windows: 7d (early read), 14d (standard), 30d. A cohort is CLOSED for
-- window N when cohort_age_days >= N + 6, where age is measured from the LAST COMPLETE backend day (data_end), not today (last cohort day + N days). Open cohorts are "pending", never "failed".
-- Lag (2026-10-02..10-25 cohorts): deposit p75 2d / p90 10d; investment p75 6d / p90 15d.
WITH ev AS (
  SELECT profile_id, event_name, DATE(occurred_at, 'Asia/Riyadh') AS d, JSON_VALUE(context.platform) AS platform
  FROM `databases-472111.manafa_financing.mi_analytics_events`
  WHERE profile_id IS NOT NULL
    AND event_name IN ('registration_completed','identity_verified','kyc_completed','deposit_success','investment_completed')
),
data_end AS (
  -- last complete day = day before the newest (possibly partial) day in the replica
  SELECT DATE_SUB(MAX(DATE(occurred_at, 'Asia/Riyadh')), INTERVAL 1 DAY) AS d_end
  FROM `databases-472111.manafa_financing.mi_analytics_events`
),
reg AS (
  SELECT profile_id, MIN(d) AS reg_date, ARRAY_AGG(platform ORDER BY d LIMIT 1)[OFFSET(0)] AS reg_platform
  FROM ev WHERE event_name = 'registration_completed' GROUP BY 1
),
firsts AS (
  SELECT profile_id,
    MIN(IF(event_name = 'identity_verified', d, NULL)) AS idv,
    MIN(IF(event_name = 'kyc_completed', d, NULL)) AS kyc,
    MIN(IF(event_name = 'deposit_success', d, NULL)) AS dep,
    MIN(IF(event_name = 'investment_completed', d, NULL)) AS inv
  FROM ev GROUP BY 1
),
c AS (
  SELECT r.reg_date, r.reg_platform,
    DATE_DIFF(f.idv, r.reg_date, DAY) AS t_idv, DATE_DIFF(f.kyc, r.reg_date, DAY) AS t_kyc,
    DATE_DIFF(f.dep, r.reg_date, DAY) AS t_dep, DATE_DIFF(f.inv, r.reg_date, DAY) AS t_inv
  FROM reg r LEFT JOIN firsts f USING (profile_id)
  WHERE r.reg_date >= '2026-10-02'   -- v2.1 backend events complete from 2026-10-02
    AND r.reg_date <= (SELECT d_end FROM data_end)
)
SELECT
  DATE_TRUNC(reg_date, ISOWEEK) AS cohort_week,
  reg_platform,
  DATE_DIFF((SELECT d_end FROM data_end), DATE_TRUNC(reg_date, ISOWEEK), DAY) AS cohort_age_days,
  COUNT(*) AS registrations,
  COUNTIF(t_idv BETWEEN 0 AND 7) AS identity_verified_7d,
  COUNTIF(t_kyc BETWEEN 0 AND 7) AS kyc_7d,   COUNTIF(t_kyc BETWEEN 0 AND 14) AS kyc_14d,   COUNTIF(t_kyc BETWEEN 0 AND 30) AS kyc_30d,
  COUNTIF(t_dep BETWEEN 0 AND 7) AS deposit_7d, COUNTIF(t_dep BETWEEN 0 AND 14) AS deposit_14d, COUNTIF(t_dep BETWEEN 0 AND 30) AS deposit_30d,
  COUNTIF(t_inv BETWEEN 0 AND 7) AS invest_7d,  COUNTIF(t_inv BETWEEN 0 AND 14) AS invest_14d,  COUNTIF(t_inv BETWEEN 0 AND 30) AS invest_30d
FROM c
GROUP BY 1, 2, 3
