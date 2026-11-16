-- weekly_kpis: production backend KPIs per ISO week (Riyadh). Aggregated, no PII.
-- Amounts are per currency (deposits arrive in SAR and USD); never add currencies together.
SELECT
  DATE_TRUNC(DATE(occurred_at, 'Asia/Riyadh'), ISOWEEK) AS iso_week,
  event_name,
  JSON_VALUE(payload.currency) AS currency,
  COUNT(*) AS events,
  COUNT(DISTINCT profile_id) AS unique_profiles,
  SUM(SAFE_CAST(JSON_VALUE(payload.amount) AS NUMERIC)) AS amount,
  COUNTIF(SAFE_CAST(JSON_VALUE(payload.is_first_investment) AS BOOL)) AS first_investments,
  COUNTIF(SAFE_CAST(JSON_VALUE(payload.is_auto_invested) AS BOOL)) AS auto_investments
FROM `databases-472111.manafa_financing.mi_analytics_events`
WHERE event_name IN ('registration_completed','identity_verified','kyc_completed','deposit_success','deposit_failed',
                     'investment_completed','investment_cancelled','auto_invest_enabled','withdrawal_settled')
  AND DATE(occurred_at, 'Asia/Riyadh') >= '2026-10-02'
GROUP BY 1, 2, 3
