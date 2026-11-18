-- GA4 duplicate check (tracking QA, GA4 only): per ISO week and event, server-sent events (with event_uuid)
-- vs extra copies without event_uuid (forwarded again by Singular/SDK on the app streams, tqa-007).
SELECT DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), ISOWEEK) AS wk, event_name,
 COUNTIF((SELECT value.string_value FROM UNNEST(event_params) WHERE key='event_uuid') IS NOT NULL) AS server_sent,
 COUNTIF((SELECT value.string_value FROM UNNEST(event_params) WHERE key='event_uuid') IS NULL) AS extra_copies
FROM `databases-472111.google_analytics.events_*`
WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$') AND _TABLE_SUFFIX >= '20261104' AND event_name IN ('registration_completed','login_completed','kyc_completed','identity_verified','withdrawal_completed','passcode_enabled','bank_account_added','auto_invest_disabled','deposit_success','investment_completed')
GROUP BY 1, 2 ORDER BY 1, 2
