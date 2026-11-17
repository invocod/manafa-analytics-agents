# Singular — Google Sheet exception (user decision, 2026-11-17)

Singular cannot export to BigQuery today. **For Singular only**, the loops read this Google Sheet. GA4 and Google Ads stay BigQuery-only, and so does the backend ledger.

- **Sheet:** https://docs.google.com/spreadsheets/d/1t885guR7b8CdkpxlQN-s0LDC_FOnvye8mmuh0d6mItg (tab `Sheet1`, gid 0). Shared inside the Manafa Google domain (sign-in required).
- **How to read (2026-11-17):** the **Google Sheets connector** (`get_values` on `Sheet1`, spreadsheet ID above) — works in scheduled cloud runs, no Chrome needed. Connector check 2026-11-17: header identical, 671 data rows (rows 2–672), last date 2026-11-16 — matches the Chrome read. The connector also returns `adn_campaign_id` / `adn_account_id` / `adn_sub_campaign_id`, which the Chrome gviz export dropped. Fallback only if the connector is unavailable: signed-in Chrome, `fetch('/spreadsheets/d/<id>/gviz/tq?tqx=out:csv&gid=0')`. **Read-only:** never write to `Sheet1` (Singular's ETL appends there). Return only aggregates; never copy raw rows into the repo, state, Slack or the Command Center.
- **What it is:** a Singular **ad-network report** (Singular's ETL appends daily, `etl_query_timestamp_utc`). It has spend, impressions, clicks and network-claimed installs plus Singular-attributed `app_install_count`, by date × network × OS × country × campaign × sub-campaign (Google Ads also × sub-network: Search / Display / Search Partners). **It has no conversion events** (no registration, deposit or investment by network). App: "Manafa-App 2025". Currency column `adn_original_currency` (SAR only so far).
- **PII check (2026-11-17):** none. Columns are campaign-level aggregates. `data_connector_username` / `adn_account_name` are ad-account handles, not customers. Re-check the header each run; if any user/device-level column appears (device ID, IDFA/GAID, user ID, email, phone), **stop and report** — do not process.

## Daily read: the `mbi_summary` tab (added 2026-11-17, user approved)
Loops read **`mbi_summary`** (sheetId 601531578), not raw `Sheet1` rows. It is formulas only; Sheet1 is never written.
- `A1` = QUERY: one row per `date × source × os × currency` with `impressions, clicks, network_installs, cost, attributed_installs, rows` (read `mbi_summary!A:J`).
- `L1:M12` = checks: `header`, `data_rows`, `min_date`, `max_date`, `max_etl_utc`, `duplicate_grain_rows`, `currencies`, `cost_total_check` (SUMPRODUCT over Sheet1), `installs_check` (network / attributed), `table_cost_total`, `table_rows_total`.
- **Gate (all must hold, else report "stale/invalid data — Singular sheet" and skip the Singular section):** header equals the column list above and has no PII-like column; `duplicate_grain_rows` = 0; `currencies` = SAR only (otherwise split by currency); `table_cost_total` = `cost_total_check` and `table_rows_total` = `data_rows` (two independent computations); `max_date` ≥ run date − 2.
- Need campaign-level detail (e.g. tqa-018)? Read only the needed columns of Sheet1 for the needed dates.
- If someone deletes or edits the tab, rebuild it from this section; never put formulas in Sheet1.
- Check at creation (2026-11-17): 671 rows, 2026-10-11 → 2026-11-16, 0 duplicates, SAR, cost 119,513.29, installs 3,389 / 9,928 — identical to the Chrome read.

## Columns
`date, etl_query_timestamp_utc, app, source, os, platform, country_field, adn_campaign_id, adn_campaign_name, adn_account_id, adn_original_currency, adn_campaign_url, adn_sub_campaign_name, adn_sub_adnetwork_name, adn_account_name, adn_sub_campaign_id, data_connector_source_name, data_connector_id, data_connector_username, data_connector_timestamp_utc, adn_impressions, adn_clicks, adn_installs, adn_cost, adn_original_cost, app_install_count`

## Validation every run (before any number is used)
1. Header unchanged and PII-free (see above).
2. Grain unique on `date, source, os, country_field, adn_campaign_name, adn_sub_campaign_name, adn_sub_campaign_id, adn_account_name, adn_sub_adnetwork_name`. Any duplicate → stop; the sheet may have appended a restated snapshot.
3. Each `date × source` comes from one ETL load day.
4. Never sum `adn_cost` across currencies.
5. Freshness: max `date` and max `etl_query_timestamp_utc`; 72-hour rule applies (networks restate recent days).

## Reporting rules
- Singular figures go in their **own "Singular (attribution)" section**, labelled "Singular sheet". Never blended, summed, averaged or divided with GA4, Google Ads (BigQuery) or backend numbers.
- `adn_installs` = network-claimed installs; `app_install_count` = Singular-attributed installs. Report both, labelled, never as one "installs".
- Twitter rows carry spend/clicks but no installs (no install postback) — say "installs not reported", not zero.
- Google Ads spend: **BigQuery stays the truth**; the sheet's AdWords rows are used only by bi-tracking-health as a cross-check (see tqa-018).

## Baseline at connect (2026-11-17)
671 rows, 2026-10-11 → 2026-11-16, 37 dates, networks AdWords / TikTok Ads / Twitter, OS iOS / Android / Web, currency SAR only, no full-grain duplicates.
