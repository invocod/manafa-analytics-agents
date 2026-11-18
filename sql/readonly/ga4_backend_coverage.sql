-- ga4_backend_coverage: TRACKING QA ONLY (bi-tracking-health). Never a reported stat.
-- GA4 server-sent events (one per event_uuid, raw export) as a share of backend events, per ISO week.
-- Drives the GA4-readiness check (CLAUDE.md): when every key event stays within 0.98-1.02 for 2 consecutive
-- closed weeks where both sources cover the whole week, tell Amir the agents can move to GA4. Never switch automatically.
-- Only judge weeks that are closed in BOTH sources (backend replica lags, tqa-023; exclude the trailing 72 h).
WITH g AS (
  SELECT DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), ISOWEEK) AS wk, event_name,
    COUNT(DISTINCT (SELECT value.string_value FROM UNNEST(event_params) WHERE key='event_uuid')) AS ga4_server_sent
  FROM `databases-472111.google_analytics.events_*`
  WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= '20261109'
    AND event_name IN ('registration_completed','kyc_completed','identity_verified','deposit_success','investment_completed','auto_invest_enabled')
  GROUP BY 1, 2),
b AS (
  SELECT DATE_TRUNC(DATE(occurred_at, 'Asia/Riyadh'), ISOWEEK) AS wk, event_name, COUNT(*) AS backend
  FROM `databases-472111.manafa_financing.mi_analytics_events`
  WHERE DATE(occurred_at, 'Asia/Riyadh') >= '2026-11-09'
    AND event_name IN ('registration_completed','kyc_completed','identity_verified','deposit_success','investment_completed','auto_invest_enabled')
  GROUP BY 1, 2)
SELECT wk, event_name, backend, IFNULL(ga4_server_sent, 0) AS ga4_server_sent, ROUND(SAFE_DIVIDE(ga4_server_sent, backend), 3) AS coverage
FROM b LEFT JOIN g USING (wk, event_name)
ORDER BY wk, event_name
