# Data Sources & Access

**Current reality (updated 2026-11-11): three sources — GA4, Google Ads, Singular — all via CSV exports dropped into `data/exports/`. BigQuery integration is planned and will become the backend source of truth when it lands.**

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

### 4. BigQuery (planned — becomes the source of truth)
- When integrated, backend events are queried directly (aggregates only) and replace the GA4 interim ledger. The loops' "backend" references then point here. Access via the BigQuery connector / service account; update this file and `CLAUDE.md`'s interim note when it lands.

### Not active (no data yet)
Meta / TikTok / Snapchat exports (`data/exports/meta|tiktok|snapchat/`) and direct backend CSVs (`data/exports/backend/`) — folders exist; loops treat them as **not configured** (skipped and named in "not covered"), distinct from a configured source gone **stale**.

## Freshness

A source with no file newer than 8 days is **stale**: loops say so and never fill the gap from memory. Export → save into the folder → (once on GitHub: commit + push).

## Slack delivery

- Channel: `#marketing-loops` — dedicated channel for loop output (create it in Slack if it doesn't exist yet; invite the marketing team).
- Posted via the Slack connector attached to each scheduled routine. Message = the report's verdict + top findings; full report is committed under `reports/`.

## PDPL rule

Exports contain **aggregate rows only** — by date/campaign/source, never by user. If an export arrives with user-level rows or any PII column, the loop must refuse to process it, flag it in the report, and the file gets deleted — not committed.
