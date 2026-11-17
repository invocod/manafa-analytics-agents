-- users_backend_profile: what backend events say about users' devices and preferences, last 28 complete days. Each user counted once per dimension using their most recent value (per platform; 'all' = across platforms). Login method counts users who used it at least once. Top 12 per dimension and platform. Aggregated, no PII (never device IDs).
WITH b AS (SELECT DATE_SUB(MAX(DATE(occurred_at,'Asia/Riyadh')), INTERVAL 1 DAY) AS data_end FROM `databases-472111.manafa_financing.mi_analytics_events`),
t AS (
  SELECT occurred_at AS ts, COALESCE(JSON_VALUE(context.platform),'unknown') AS platform, profile_id, event_name,
    JSON_VALUE(context.app_version) AS app_version,
    JSON_VALUE(context.vendor_keys.singular_device.os_version) AS os_version,
    INITCAP(SPLIT(JSON_VALUE(context.vendor_keys.singular_device.make),' ')[SAFE_OFFSET(0)]) AS make,
    JSON_VALUE(context.vendor_keys.singular_device.model) AS model,
    LOWER(JSON_VALUE(context.language)) AS lang,
    JSON_VALUE(context.entity_type) AS entity,
    IF(event_name='login_completed', JSON_VALUE(payload.method), NULL) AS login_method
  FROM `databases-472111.manafa_financing.mi_analytics_events`, b
  WHERE DATE(occurred_at,'Asia/Riyadh') BETWEEN DATE_SUB(b.data_end, INTERVAL 27 DAY) AND b.data_end AND profile_id IS NOT NULL),
dev AS (
  SELECT platform, profile_id,
    ARRAY_AGG(app_version IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS app_version,
    ARRAY_AGG(os_version IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS os_version,
    ARRAY_AGG(make IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS make,
    ARRAY_AGG(model IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS model
  FROM t WHERE platform IN ('ios','android') AND event_name='login_completed' GROUP BY 1, 2),
pref_p AS (SELECT platform, profile_id, ARRAY_AGG(lang IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS lang, ARRAY_AGG(entity IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS entity FROM t WHERE event_name='login_completed' GROUP BY 1, 2),
pref_a AS (SELECT 'all' AS platform, profile_id, ARRAY_AGG(lang IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS lang, ARRAY_AGG(entity IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS entity FROM t WHERE event_name='login_completed' GROUP BY 1, 2),
pref AS (SELECT * FROM pref_p UNION ALL SELECT * FROM pref_a),
l AS (
  SELECT 'app_version' AS dim, platform, app_version AS v, COUNT(*) AS users FROM dev WHERE app_version IS NOT NULL GROUP BY 1,2,3
  UNION ALL SELECT 'os_version', platform, os_version, COUNT(*) FROM dev WHERE os_version IS NOT NULL GROUP BY 1,2,3
  UNION ALL SELECT 'device_brand', platform, make, COUNT(*) FROM dev WHERE platform='android' AND make IS NOT NULL GROUP BY 1,2,3
  UNION ALL SELECT 'device_model', platform, model, COUNT(*) FROM dev WHERE model IS NOT NULL GROUP BY 1,2,3
  UNION ALL SELECT 'language', platform, lang, COUNT(*) FROM pref WHERE lang IS NOT NULL GROUP BY 1,2,3
  UNION ALL SELECT 'account_type', platform, entity, COUNT(*) FROM pref WHERE entity IS NOT NULL GROUP BY 1,2,3
  UNION ALL SELECT 'login_method', IF(GROUPING(tp)=1,'all',tp), login_method, COUNT(DISTINCT profile_id) FROM (SELECT platform AS tp, login_method, profile_id FROM t WHERE login_method IS NOT NULL) GROUP BY GROUPING SETS ((tp, login_method), (login_method)))
SELECT dim, platform, v, users, (SELECT data_end FROM b) AS data_end FROM l
QUALIFY ROW_NUMBER() OVER (PARTITION BY dim, platform ORDER BY users DESC) <= 12
ORDER BY dim, platform, users DESC
