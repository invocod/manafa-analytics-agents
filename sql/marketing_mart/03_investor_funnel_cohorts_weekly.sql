-- Signup cohorts (ISO week, Riyadh dates from the DWH) -> KYC -> first deposit -> first investment.
-- *_7d / *_30d = reached the step within N days of signup. cohort_age_days lets loops mark open cohorts as pending.
CREATE OR REPLACE VIEW `databases-472111.marketing_mart.investor_funnel_cohorts_weekly`
OPTIONS (description = 'Investor signup cohorts by week x channel with step conversion counts. No PII.') AS
SELECT
  DATE_TRUNC(signup_date, ISOWEEK)                            AS cohort_week,
  signup_channel,
  LOWER(utm_source)                                           AS utm_source,
  is_tawakkalna_signup,
  is_referred,
  DATE_DIFF(CURRENT_DATE('Asia/Riyadh'), DATE_TRUNC(signup_date, ISOWEEK), DAY) AS cohort_age_days,
  COUNT(*)                                                    AS signups,
  COUNTIF(days_signup_to_kyc BETWEEN 0 AND 7)                 AS kyc_7d,
  COUNTIF(days_signup_to_kyc BETWEEN 0 AND 30)                AS kyc_30d,
  COUNTIF(days_signup_to_first_deposit BETWEEN 0 AND 7)       AS deposit_7d,
  COUNTIF(days_signup_to_first_deposit BETWEEN 0 AND 30)      AS deposit_30d,
  COUNTIF(days_signup_to_first_investment BETWEEN 0 AND 7)    AS invest_7d,
  COUNTIF(days_signup_to_first_investment BETWEEN 0 AND 30)   AS invest_30d,
  COUNTIF(is_profile_verified)                                AS verified_ever,
  COUNTIF(has_deposited)                                      AS deposited_ever,
  COUNTIF(has_invested)                                       AS invested_ever,
  SUM(total_deposited_sar)                                    AS total_deposited_sar,
  SUM(total_invested_sar)                                     AS total_invested_sar,
  MAX(dwh_built_at)                                           AS dwh_built_at
FROM `databases-472111.gold.fact_investor_journey`
WHERE signup_date IS NOT NULL
GROUP BY 1,2,3,4,5,6;
