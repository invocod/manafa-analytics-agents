-- Backend conversion ledger (server-fired Laravel events), one row per Riyadh day x event x platform x acquisition.
-- Truth for: registration_completed, kyc_completed, identity_verified, deposit_success, investment_completed, ...
-- Excludes legacy loyalty events removed from the product (stamp_collected, wheel_spin_completed).
CREATE OR REPLACE VIEW `databases-472111.marketing_mart.backend_events_daily`
OPTIONS (description = 'Aggregated backend analytics events per Riyadh day. No PII.') AS
SELECT
  DATE(occurred_at, 'Asia/Riyadh')                          AS event_date,
  event_name,
  subject_type,
  JSON_VALUE(context.platform)                              AS platform,
  JSON_VALUE(attribution.first_platform)                    AS first_platform,
  LOWER(JSON_VALUE(attribution.acquisition_source))         AS acquisition_source,
  LOWER(JSON_VALUE(attribution.acquisition_medium))         AS acquisition_medium,
  LOWER(JSON_VALUE(attribution.acquisition_campaign))       AS acquisition_campaign,
  LOWER(JSON_VALUE(attribution.last_source))                AS last_source,
  LOWER(JSON_VALUE(attribution.last_medium))                AS last_medium,
  LOWER(JSON_VALUE(attribution.last_campaign))              AS last_campaign,
  SAFE_CAST(JSON_VALUE(payload.is_first_investment) AS BOOL) AS is_first_investment,
  SAFE_CAST(JSON_VALUE(payload.is_auto_invested) AS BOOL)   AS is_auto_invested,
  JSON_VALUE(payload.currency)                              AS currency,
  COUNT(*)                                                  AS events,
  COUNT(DISTINCT COALESCE(CAST(profile_id AS STRING), analytics_user_id)) AS unique_subjects,
  SUM(SAFE_CAST(JSON_VALUE(payload.amount) AS NUMERIC))     AS amount
FROM `databases-472111.manafa_financing.mi_analytics_events`
WHERE event_name NOT IN ('stamp_collected', 'wheel_spin_completed')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14;
