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
Source: `GA4` transfer (property 413046941): `ga4_events_daily.sql`, `ga4_traffic_daily.sql`, `ga4_user_acquisition_daily.sql`.
- Sessions, engaged sessions, event counts, channel/source/medium (last touch = session; first touch = first user).
- Caveats: all streams (QA streams can't be excluded until the raw export lands); 7 events doubled (tqa-007), so never report GA4 counts of registration/KYC/login/withdrawal_completed/passcode_enabled/bank_account_added as conversions.
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

## Not available (named, never estimated)
Singular conversion events (registration/deposit/investment by network — not in the sheet), Meta/TikTok/Snapchat spend, GA4 platform/stream split, channel attribution of backend conversions (tqa-014), anything from `gold` (tqa-012).
