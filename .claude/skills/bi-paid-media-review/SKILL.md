---
name: bi-paid-media-review
description: "Weekly paid-media review on BigQuery (Google Ads today; Meta/TikTok/Snapchat once in BigQuery): fixed-order check of spend → traffic → conversions → creative → landing → tracking, ending in exactly one HOLD/FIX/TEST/INVESTIGATE call per account. Stages plans; never touches live accounts."
---

# Paid-Media Review Loop

One decision per ad account per week. State: `state/bi-paid-media-review.json` + `.log`.

| Part | Spec |
|---|---|
| **Cadence** | Weekly (Monday) |
| **Acts when** | A metric leaves its trailing 6–8 week range, moves the same way 3+ weeks, or crosses a target in `context/manafa-marketing.md`. Spend pacing breaks, tracking problems and broken landing pages act immediately. |
| **Stop / bail-out** | **Never change budgets, bids, campaign status, tracking or ads.** Staged plans only. Less than 4 weeks of history → ranges are provisional; say so. |
| **Output** | One call per account + facts / hypotheses / missing data |

## Before every run (all bi-* loops)

1. Read `CLAUDE.md`, `context/metrics.md` and this loop's `state/<loop>.json`.
2. Run `sql/readonly/source_freshness.sql`. Use only complete days: the backend replica's newest day is usually partial, and the trailing 72 hours are never judged. A source older than 8 days is **stale**: report "stale data — <source>", do not advance the cursor, halt if it is a required source.
3. BigQuery only (`databases-472111`, me-central2), read-only (`execute_sql_readonly`). Build numbers from `context/metrics.md` definitions and `sql/readonly/` queries; aggregated output only. `gold`/`silver`/`curated`/`reporting`/`dashboard_views`/`sama_mart` are suspended (tqa-012).
4. Not in BigQuery = **not configured** (Meta, TikTok, Snapchat platform data, GA4 platform split). Name them under "Not covered"; never estimate them. **Exception: Singular** is read from its Google Sheet per `context/singular-sheet.md` (validate first; own "Singular (attribution)" section; never blended).
5. After the run: write the report to `reports/<yyyy>/W<ww>/`, update state, append one log line (plus `decision:` lines), commit.
6. Report the run live to the Command Center exactly as `docs/command-center.md` says: statuses and steps as they actually happen, never estimated.

## Loop body

1. **Accounts in scope**: Google Ads (`gads_campaign_daily`, `gads_conversions_daily`). Meta/TikTok/Snapchat/X = not configured until their data is in BigQuery.
2. Per account, **in this fixed order**: spend & pacing (vs trailing weeks) → traffic (clicks, CPC, CTR) → conversions (Google Ads claimed per action and claimed CPA; next to it, in its own column, GA4 server-sent conversions for the same campaigns from `ga4_conversions_by_channel.sql` (Paid Search / Cross-network channel, campaign name), labelled GA4 and a floor; CLAUDE.md rule 5; never a blended CPA) → creative fatigue (CTR vs its peak) → landing (campaign final URLs follow the UTM convention) → tracking (open bi-tracking-health issues on this account, e.g. tqa-016).
3. Compare each metric to the weekly snapshots in state.
4. Per mover: facts vs hypotheses vs missing data.
5. **Exactly one call per account**: HOLD / FIX (named issue + staged plan) / TEST (brief) / INVESTIGATE (data can't be trusted; name the one settling check).

## Self-check
Conversion lag or learning phase? Platform-vs-backend disagreement → INVESTIGATE, not FIX. Same week for spend and conversions?

## Output
```
📊 Paid media — week <ww>  (spend: X <currency>)
| Account | Call | Why |
Staged for approval: … | Missing data: …
```
