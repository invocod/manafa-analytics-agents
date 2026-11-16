# Data Sources & Access

**Current reality (updated 2026-11-16): BigQuery is the only source of truth** (`databases-472111`, `me-central2` / Saudi Arabia only). CSV/Excel exports in `data/exports/` are ignored by every loop. Singular, Meta, TikTok and Snapchat are **not configured** until their data lands in BigQuery (in me-central2).

## Retired: CSV sources (ignored since 2026-11-16)
GA4, Singular and Google Ads CSV drops under `data/exports/` are no longer read. The files stay for history only. Do not use them to fill gaps.

## BigQuery — CONNECTED, sole source of truth 2026-11-16 (data residency: Saudi Arabia only)
- **Project:** `databases-472111` (project number 1088110471445). Access via the Google Cloud BigQuery connector (read-only tool `execute_sql_readonly`).
- **Region rule (user requirement, 2026-11-16): all Manafa data lives in and is processed in `me-central2` (Dammam, Saudi Arabia).** Every query targets `me-central2` datasets; INFORMATION_SCHEMA queries use `` `region-me-central2` ``. Never create datasets, tables, exports or scheduled queries in `US`, `EU` or any non-Saudi region, and never copy Manafa data out of `me-central2`. The `US` region in this project is empty and stays unused.
- **Aggregates only (PDPL):** queries return counts/sums grouped by date/event/channel/campaign. Never select names, national IDs, phones, emails, IBANs, `payload`/`context`/`attribution` JSON values per user, or individual transaction rows. `user_id`/`profile_id` may be used inside `COUNT(DISTINCT ...)`, never output.

| Use | Table (all in `databases-472111`, me-central2) | Grain / freshness at connect (2026-11-16) |
|---|---|---|
| **Backend event ledger (conversion truth)** | `manafa_financing.mi_analytics_events` (`event_name`, `occurred_at`, `profile_id`, `user_id`, `analytics_user_id`, JSON `payload/context/attribution`) | one row per server-fired event; registration/investment since 2026-09-07, most v2.1 events since 2026-10-02; replica last updated 2026-11-12 (~3–4 day lag) |
| Backend → vendor delivery log (tracking QA) | `manafa_financing.mi_analytics_event_deliveries` (`channel` ga4/singular, `status`, `attribution_scope`, `degraded_reason`) | one row per event × vendor; same freshness |
| Investor funnel / cohorts | `gold.fact_investor_journey` (signup, KYC, first deposit, first investment dates, `utm_source`, `signup_channel`, lag columns) | one row per investor, signups 2020-07-08 → 2026-11-11; dwh build 2026-11-11 |
| Investments, investors, leads | `gold.fact_investment`, `gold.dim_investor`, `gold.fact_lead` | dwh build 2026-11-11 |
| GA4 (product analytics) | `GA4.p_ga4_Events_413046941`, `p_ga4_TrafficAcquisition_…`, `p_ga4_UserAcquisition_…`, `p_ga4_LandingPage_…`, `p_ga4_PagesAndScreens_…`, `p_ga4_TechDetails_…` (property 413046941) | **GA4 Data Transfer (report-level aggregates, daily partitions)**, not the raw `events_*` export; 2026-11-06 → 2026-11-15 only |
| Google Ads (claims + spend) | `google_ads.p_ads_CampaignStats_3343082801`, `p_ads_CampaignConversionStats_…`, `p_ads_Campaign_…` (customer 3343082801) | Data Transfer; 2026-11-07 → 2026-11-15; cost in `metrics_cost_micros` |
| Singular | — not in BigQuery yet → **not configured** (ask for the Singular → BigQuery export in me-central2) | |

- **Query surface now: `sql/readonly/*.sql`** (read-only SELECTs, validated 2026-11-16). Access is read-only, so the `marketing_mart` dataset (`sql/marketing_mart/`) is deferred to the deploy phase.
- **Not for marketing loops:** `stg_staging_financing` (staging env), `curated_v1`, `gold_prod_snapshot`, `*_test`, `*_poc`, `*_scratch`, `sama_mart`, `silver` (contains raw customer tables, so don't query it).
- **Open items at connect:** (1) GA4 and Google Ads transfers hold ~10 days, so request a backfill (8+ weeks) for baselines. (2) The raw GA4 event export (`analytics_413046941`) is not in me-central2; confirm whether it exists and create it in me-central2 if needed. (3) The backend replica lags ~3–4 days (fits the 72-hour rule, but check before each run). (4) Singular → BigQuery is still pending. (5) CSVs are retired (user decision, 2026-11-16). Loops read BigQuery only.

### Not active (no data yet)
Meta / TikTok / Snapchat exports (`data/exports/meta|tiktok|snapchat/`) and direct backend CSVs (`data/exports/backend/`) — folders exist; loops treat them as **not configured** (skipped and named in "not covered"), distinct from a configured source gone **stale**.

## Freshness

A BigQuery source whose latest partition/row is older than 8 days is **stale**. Loops say so and never fill the gap from memory or files. Check `INFORMATION_SCHEMA.TABLE_STORAGE` (`region-me-central2`) or the max date before each run.

## Slack delivery

- Channel: `#marketing-loops` — dedicated channel for loop output (create it in Slack if it doesn't exist yet; invite the marketing team).
- Posted via the Slack connector attached to each scheduled routine. Message = the report's verdict + top findings; full report is committed under `reports/`.

## PDPL rule

BigQuery queries return **aggregate rows only** — by date/campaign/source, never by user. If an export arrives with user-level rows or any PII column, the loop must refuse to process it, flag it in the report, and the file gets deleted — not committed.
