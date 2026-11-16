# Data Sources & Access

**Current reality (updated 2026-11-16): BigQuery is connected (`databases-472111`, region `me-central2` / Saudi Arabia only). It holds the backend event ledger, GA4 and Google Ads, so see section 4. Singular remains a CSV drop. The CSV exports in `data/exports/` keep working while BigQuery is validated.**

## Source roles (until BigQuery)

The north star stays: backend events (`registration_completed`, `kyc_completed`, `deposit_success`, `investment_completed`) define conversion counts. Until BigQuery exposes them directly, **no tool stands in for the backend**. Each source is reported in its own section with its own numbers (user preference, 2026-11-11):

| Source | Role | Reported as |
|---|---|---|
| GA4 | Product analytics: sessions, users, engagement, events across web and apps | GA4 section |
| Singular | Attribution: app installs and conversions by network/campaign, plus web campaign tracking | Singular section |
| Google Ads | Platform claims and spend | Its own section (weekly-ads-check) |

Rules: never sum, blend or ratio across sources in a stat. Cross-source comparisons happen only inside tracking-QA as data-quality checks, and their output is an issue, not a number. Known GA4 caveat: registration/KYC (and login, withdrawal_completed, passcode_enabled, bank_account_added) look double-counted in the apps (tqa-007). Flag it in the GA4 section; don't replace the number with Singular's.

## Sources

### 1. GA4 — CSV export (product analytics, web + apps)
- Drop into: **`data/exports/ga4/`** — e.g. `ga4-2026-11-11.csv`
- Useful exports (any subset; loops adapt to the columns present and say what they couldn't check):
  - Daily key-event counts by event name (most important)
  - Sessions by session source/medium/campaign (UTM audit + channel checks)
  - Sessions/key events by default channel group (Unassigned share)
- Platform splits (source/medium × platform, events × stream × platform) need GA4 Explore. Step-by-step setups are in `context/ga4-explore-recipes.md`.
- Key-event list (Admin → Data display → Events: names marked as key events, with counting method) feeds tracking-QA check 7. The standard it's checked against is `context/playbooks/ga4-event-standards.md`.
- Include as much history as convenient (8+ weeks makes the weekday bands real). Date, dimension columns, metric columns — the loop reads whatever shape GA4's export produces; keep the header row.
- Later: GA4 Data API (`GA4_SERVICE_ACCOUNT_JSON` + `GA4_PROPERTY_ID`) or the GA4→BigQuery export replaces the manual drop.

### 2. Singular — CSV export (app installs + in-app conversions by source)
- Drop into: **`data/exports/singular/`** — e.g. `singular-2026-11-11.csv`
- Useful columns: date, source/network, campaign, installs, conversion events (names + counts), spend if present.
- Later: Singular Reporting API (`SINGULAR_API_KEY`).

### 3. Google Ads — CSV export (claims + spend)
- Drop into: **`data/exports/google-ads/`** — e.g. `google-ads-2026-11-11.csv`
- Useful columns: date, campaign, cost, impressions, clicks, conversions, conversion action.
- Exports the loops ask for, in priority order:
  1. **Conversion actions:** Goals → Conversions → Summary, all actions (tracking-QA check 6, `context/playbooks/google-ads-conversion-audit.md`).
  2. **Campaigns × conversion action × day**, last 8 weeks (weekly-ads-check).
  3. **Search terms**, unfiltered, last closed week (query-mining loop, Phase 1).
- Read with `context/playbooks/reading-google-ads-data.md` and `ads-audit-guardrails.md`.

### 4. BigQuery — CONNECTED 2026-11-16 (data residency: Saudi Arabia only)
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
| Singular | — not in BigQuery yet (CSV drops continue) | |

- **Not for marketing loops:** `stg_staging_financing` (staging env), `curated_v1`, `gold_prod_snapshot`, `*_test`, `*_poc`, `*_scratch`, `sama_mart`, `silver` (contains raw customer tables, so don't query it).
- **Open items at connect:** (1) GA4 and Google Ads transfers hold ~10 days, so request a backfill (8+ weeks) for baselines. (2) The raw GA4 event export (`analytics_413046941`) is not in me-central2; confirm whether it exists and create it in me-central2 if needed. (3) The backend replica lags ~3–4 days (fits the 72-hour rule, but check before each run). (4) Singular → BigQuery is still pending. (5) Until the backend counts are validated against GA4 in one tracking-QA run, loops keep the CSV workflow and add BigQuery as its own "Backend" section.

### Not active (no data yet)
Meta / TikTok / Snapchat exports (`data/exports/meta|tiktok|snapchat/`) and direct backend CSVs (`data/exports/backend/`) — folders exist; loops treat them as **not configured** (skipped and named in "not covered"), distinct from a configured source gone **stale**.

## Freshness

A source with no file newer than 8 days is **stale**: loops say so and never fill the gap from memory. Export → save into the folder → (once on GitHub: commit + push).

## Slack delivery

- Channel: `#marketing-loops` — dedicated channel for loop output (create it in Slack if it doesn't exist yet; invite the marketing team).
- Posted via the Slack connector attached to each scheduled routine. Message = the report's verdict + top findings; full report is committed under `reports/`.

## PDPL rule

Exports contain **aggregate rows only** — by date/campaign/source, never by user. If an export arrives with user-level rows or any PII column, the loop must refuse to process it, flag it in the report, and the file gets deleted — not committed.
