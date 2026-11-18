---
name: bi-weekly-exec-digest
description: "The Monday executive digest: production funnel KPIs vs last week and trailing weeks, GA4 and Google Ads each in their own section, biggest movers tied to an owner or loop, and this week's loop verdicts in one page. Always runs, last."
---

# Weekly Executive Digest Loop

One page management actually reads. Runs after bi-tracking-health, bi-investor-funnel, bi-channel-attribution and bi-paid-media-review. State: `state/bi-weekly-exec-digest.json` + `.log`.

| Part | Spec |
|---|---|
| **Cadence** | Weekly, Monday, last |
| **Acts when** | Always runs; flags notable movers |
| **Stop / bail-out** | Source outage → "stale data — <source>", never fabricate movement. If bi-tracking-health escalated, lead with it and badge affected numbers "measurement suspect". |
| **Output** | Digest → `reports/<yyyy>/W<ww>/weekly-exec-digest.md` (+ Slack when configured) |

## Before every run (all bi-* loops)

1. Read `CLAUDE.md`, `context/metrics.md` and this loop's `state/<loop>.json`.
2. Run `sql/readonly/source_freshness.sql`. Use only complete days: the backend replica's newest day is usually partial, and the trailing 72 hours are never judged. A source older than 8 days is **stale**: report "stale data — <source>", do not advance the cursor, halt if it is a required source.
3. BigQuery only (`databases-472111`, me-central2), read-only (`execute_sql_readonly`). Build numbers from `context/metrics.md` definitions and `sql/readonly/` queries; aggregated output only. `gold`/`silver`/`curated`/`reporting`/`dashboard_views`/`sama_mart` are suspended (tqa-012).
4. Not in BigQuery = **not configured** (Meta, TikTok, Snapchat platform data, GA4 platform split). Name them under "Not covered"; never estimate them. **Exception: Singular** is read from its Google Sheet per `context/singular-sheet.md` (validate first; own "Singular (attribution)" section; never blended).
5. After the run: write the report to `reports/<yyyy>/W<ww>/`, update state, append one log line (plus `decision:` lines), commit.
6. Report the run live to the Command Center exactly as `docs/command-center.md` says: statuses and steps as they actually happen, never estimated.

## Loop body

1. **Backend KPIs** (`weekly_kpis.sql`): last closed week vs previous week and vs the trailing 4-week median: registrations, first investments, deposits (count + amount per currency), investments (count + amount per currency), auto-invest. If the backend replica doesn't cover the full week, report the covered days and compare like-for-like days only.
2. **Funnel headline** from bi-investor-funnel (latest closed cohort, 14d, by platform).
3. **GA4 section** (own numbers): sessions, engaged sessions, channel mix.
3b. **Coverage line** (CLAUDE.md rule 5): one sentence saying the Command Center shows GA4 server-sent conversions and how much of the backend each covers this week (from bi-tracking-health), so readers know why the page shows lower numbers. Add "GA4 READY" here if bi-tracking-health reported it.
4. **Google Ads section** (own numbers): spend, clicks, claimed conversions.
5. **Fold in loop verdicts**: tracking-health verdict + top issues, attribution headline, paid-media calls.
6. **Biggest mover per stage** (best and worst) outside normal weekly variance or part of a 3-week run; tie each to an owner or loop.
7. **1–2 experiment ideas** earned by this week's data; propose Learnings rows only from a finished test or a 2+ week pattern, for approval.

## State
`{"cursor": "<last week>", "snapshots": {"2026-W45": {...}}}`. Snapshots make week-over-week exact; never recompute history from a restating source.

## Output
```
📅 Manafa weekly digest — week <ww>
Measurement: ✅ clean / ⚠️ <headline> / 🚨 <escalation>
Backend (truth) | Metric | This wk | Last wk | 4-wk median | Δ |
Funnel (14d, closed cohort <wk>): KYC _% · deposit _% · invest _% (web / iOS / Android)
GA4 (analytics) | sessions … | channel mix …
Command Center (GA4) covers: reg _% · KYC _% · dep _% · inv _% of backend
Google Ads | spend … | claimed conv …
Movers: ⬆ … / ⬇ … (owner) | Paid calls: … | Experiments: … | Proposed learnings: …
Not covered / stale: …
```
