# Metric definitions (single source of truth)

Every number a loop reports comes from one definition below. Two loops asking the same question use the same query and get the same answer.
All sources: BigQuery `databases-472111`, `me-central2`, **read-only**. Timezone: **Asia/Riyadh**. Week: **ISO week (Mon–Sun)**.
Never judge the trailing 72 hours. Check `sql/readonly/source_freshness.sql` first: the backend replica lags about 3–4 days, and its last day can be partial.

## Conversion ledger (production backend)
Source: `manafa_financing.mi_analytics_events` (Laravel, server-fired). Queries: `weekly_kpis.sql`, `backend_events_daily.sql`.
History is valid from **2026-10-02** (earlier days hold a launch burst and miss KYC/deposit events).

| Metric | Definition | Notes |
|---|---|---|
| Registrations | count of `registration_completed` | 1 event = 1 new profile (verified 1:1) |
| Identity verified | count of `identity_verified` | includes existing users re-verifying |
| KYC completed | count of `kyc_completed` | **not a new-user step**: ~63% are existing profiles; for funnels use cohorts |
| Deposits | count of `deposit_success`; amount = SUM(payload.amount) **per currency** | SAR + USD; never add currencies |
| Investments | count of `investment_completed`; amount per currency | offering-driven spikes are expected; `is_first_investment` flags new investors |
| First investments | `investment_completed` with `is_first_investment = true` | activation metric |
| Auto-invest | `auto_invest_enabled`; `is_auto_invested` on investments | |

Excluded always: `stamp_collected`, `wheel_spin_completed` (retired module), anything from `stg_*`, `*_test`, `gold` (tqa-012).

## Funnel (cohorts)
Source: `investor_funnel_cohorts_prod.sql`. Cohort = registration week (first `registration_completed` per profile).
- Rate = step reached within N days of registration ÷ cohort registrations. **Standard window: 14 days**; 7d = early read; 30d = late.
- A cohort is closed for window N when `cohort_age_days >= N + 6`. Open cohorts are **pending**, never failed.
- Lag (cohorts 2–25 Oct): deposit p75 2d / p90 10d; investment p75 6d / p90 15d.
- Always split by `reg_platform` (web vs iOS vs Android). The platforms differ ~3× at KYC.

## GA4 (product analytics), own section only
Source (since 2026-11-18): raw GA4 BigQuery export `google_analytics.events_YYYYMMDD` (production copy; streams iOS 6313772845, Android 6314084012, Web 6314227817) via `ga4_events_daily.sql`, `ga4_traffic_daily.sql`, `ga4_user_acquisition_daily.sql`, `users_ga4_*.sql`. Daily tables only (`REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\d{8}$')`), always with a `_TABLE_SUFFIX` date filter. The `GA4.p_ga4_*` transfer is retired. Data starts 2026-11-04 (1–3 Nov hold only a few test events), so GA4 baselines before that date don't exist.
- **Session** = distinct `user_pseudo_id` + `ga_session_id`; **engaged session** = `session_engaged = '1'`; **active users** = distinct `user_pseudo_id` with `is_active_user`; **new users** = distinct users with `first_open` (apps) / `first_visit` (web); **engagement time** = SUM(`engagement_time_msec`).
- **Session channel (last touch)** = `session_traffic_source_last_click.cross_channel_campaign.default_channel_group` (NULL → Unassigned); **first-user channel (first touch)** = `traffic_source.*`.
- App screen = `firebase_screen` param; web page = `page_location` path with long IDs masked.
- Never read `user_properties`, `user_id`, `user_pseudo_id`, device/advertising IDs, `gclid` or transaction IDs; they stay inside COUNT(DISTINCT) or are not used (tqa-024).
- Caveats: 7 events arrive twice (tqa-007). The extra copy has **no `event_uuid` param** and comes only on the app streams (forwarded again by Singular / the SDK). Never report raw GA4 counts of registration/KYC/login/withdrawal_completed/passcode_enabled/bank_account_added; count only events with `event_uuid` (one per uuid).
- **GA4 server-sent conversions** (used by the Command Center, user decision 2026-11-18): events from Manafa's backend that carry `event_uuid`, counted once per uuid (`sql/readonly/ga4_conversions_daily.sql`). Params: `platform` (ios/android/web, use for platform splits of these events), `currency`, `amount` (int or double), `is_first_investment` / `is_auto_invested` (0/1), internal `user_id` (inside COUNT(DISTINCT) only, never output). Cohorts: `ga4_conversion_cohorts.sql` (registration week by `user_id`, 14-day window, closed when age ≥ 20 days). Duplicate check: `ga4_duplicate_check.sql`.
- **Coverage gap (tracking QA only, W46):** GA4 server-sent events vs backend events: deposits 90.6%, investments 84.5%, registrations 79.5%, KYC 47.5%, auto_invest_enabled 40.1%, identity_verified 27.3% (deliveries the backend couldn't make, tqa-013). GA4 conversion counts are a floor; loops keep the backend ledger as conversion truth.
- Only Event Standard v2.1 names in any funnel or exploration; no legacy or `QA_` names.

## Google Ads (claims and spend), own section only
Source: `google_ads` transfer (customer 3343082801): `gads_campaign_daily.sql`, `gads_conversions_daily.sql`.
- Spend = SUM(cost_micros)/1e6 (account currency). Clicks, impressions, CTR, CPC.
- Claimed conversions per action. Platform claims never replace backend counts. CPA vs backend needs backend attribution (blocked by tqa-014), so report platform CPA as "claimed".

## Delivery health (tracking QA only)
Source: `event_delivery_health_daily.sql`. Degraded share per platform/vendor/event. Cross-tool comparisons live only here, and their output is an issue, not a stat.

## Bands (all loops)
Same weekday, **median ± max(3 × 1.4826 × MAD, 30% of median)**; provisional until 8 same-weekday points. Weekly metrics: trailing 4-week median and range. Bands live in each loop's state and are refreshed from production data only.

## Singular (own section only — Google Sheet exception)
Source: `context/singular-sheet.md`. Metrics: `singular_spend` = SUM(adn_cost) by currency; `singular_network_installs` = SUM(adn_installs) (network-claimed); `singular_attributed_installs` = SUM(app_install_count); `singular_cpi` = singular_spend / singular_attributed_installs, same window, same rows, networks with installs reported only (Twitter excluded). Riyadh-date as given by the sheet; exclude the trailing 72 h. Never combined with GA4, Google Ads (BigQuery) or backend numbers.

## Users (Command Center "Users" tab) — GA4 only since 2026-11-18
Customer activity (`sql/readonly/users_ga4_conv_summary.sql`, `users_ga4_conv_weekly.sql`; GA4 server-sent events, last 28 complete days from 4 Nov):
- **Signed-in users** = distinct internal `user_id` on server-sent `login_completed` (with `event_uuid`), split by the `platform` param; weekly chart by ISO week.
- Registrations, KYC, depositors, withdrawers, investors (manual vs auto via `is_auto_invested`; a user can be both), first-time investors (`is_first_investment`), average ticket in SAR only, auto-invest enablers.
- Callback events (identity_verified, kyc_completed, auto-invest) often never reach GA4 and are otherwise labelled web (tqa-013): read their platform split with care.
- Not shown: `days_since_registration` / `is_new_user` params (tqa-020); backend customer records (age, nationality, registered-user total). The backend-only panels (sign-in method, account type, Singular device info) were removed with the backend source.
- Backend user queries (`sql/readonly/users_backend_*.sql`) stay in the repo for loops only.
GA4 (`sql/readonly/users_ga4_*.sql`, raw export, last 7 complete days): weekly tiles use true unique users (`users_ga4_week.sql`); the daily chart shows daily actives. Demographics are country/region/city/language only (age, gender and interests are not in the export). App screens come from `firebase_screen`; ~80% of app screen views are named (tqa-021 corrected).

## Not available (named, never estimated)
Singular conversion events (registration/deposit/investment by network — not in the sheet), Meta/TikTok/Snapchat spend, channel attribution of backend conversions (tqa-014), anything from `gold` (tqa-012).
