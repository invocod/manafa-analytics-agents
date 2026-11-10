# Data Sources & Access

How each loop gets its numbers. **Hierarchy: backend > Singular/GA4 > ad platforms.** The backend defines how many; everything else explains where from.

## Sources

### 1. Backend events (source of truth)
- Events: `registration_completed`, `deposit_success`, `investment_completed` (server-fired from Laravel).
- Access: TODO — pick one and fill in:
  - [ ] Read-only reporting API endpoint (preferred): `BACKEND_REPORT_URL` + `BACKEND_REPORT_TOKEN` env vars — returns **daily aggregate counts only** (date, event, count, first-touch source if available). No row-level/user-level data.
  - [ ] Daily aggregate CSV exported to `data/exports/backend/` (see format below).
- PDPL rule: the agent only ever receives aggregates. Never expose a row-level endpoint to it.

### 2. GA4 (Data API)
- Auth: service account JSON in env var `GA4_SERVICE_ACCOUNT_JSON` (grant the service account Viewer on the property). Property ID in `GA4_PROPERTY_ID`.
- Query via the Data API (`runReport`) with curl + a JWT-signed token, or the `google-analytics-data` Python package if available.
- Used for: sessions by channel, key-event counts, funnel steps, channel-group QA ("Unassigned" share).

### 3. Singular (Reporting API)
- Auth: API key in env var `SINGULAR_API_KEY`.
- Endpoint: `https://api.singular.net/api/v2.0/reporting` (async: create report, poll, download).
- Used for: installs + in-app conversion events by source/campaign; the app-side of attribution reconciliation.

### 4. Ad platforms (Google Ads, Meta, TikTok, Snapchat) — manual CSV exports
- No direct API access. Someone exports platform reports as CSV into `data/exports/<platform>/`.
- Required columns (weekly, by campaign): date range, campaign, spend, impressions, clicks, platform-reported conversions (name the conversion action), platform currency.
- Filename convention: `{platform}-{yyyy-mm-dd}.csv` (the date the export was pulled).
- Loops treat a platform with no export fresher than 8 days as **stale** and say so — they never fill the gap from memory.

## Slack delivery

- Channel: `#marketing-loops` — TODO: confirm the real channel name.
- Posted via the Slack connector attached to each scheduled routine. Message = the report's verdict + top findings; full report is committed under `reports/`.

## Export CSV formats

### `data/exports/backend/backend-{yyyy-mm-dd}.csv` (if not using the API)
```
date,event,count,utm_source,utm_medium,utm_campaign
2026-11-09,registration_completed,142,google,cpc,registrations-investors-2026-11
```
(source/medium/campaign columns optional; aggregate counts only, no user-level rows)

### `data/exports/google-ads/google-ads-{yyyy-mm-dd}.csv`
```
date,campaign,spend_sar,impressions,clicks,conversions,conversion_action
```
Same shape for `meta/`, `tiktok/`, `snapchat/` (spend in SAR or note currency).

## Credential checklist (cloud environment)

Set these as environment secrets on the Claude cloud environment that runs the routines (claude.ai → Code → environment settings):

- [ ] `GA4_SERVICE_ACCOUNT_JSON`, `GA4_PROPERTY_ID`
- [ ] `SINGULAR_API_KEY`
- [ ] `BACKEND_REPORT_URL`, `BACKEND_REPORT_TOKEN` (if using the API option)

A loop that finds a credential missing reports "stale data — <source> unreachable" and halts; it never guesses.
