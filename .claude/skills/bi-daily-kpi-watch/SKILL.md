---
name: bi-daily-kpi-watch
description: "Daily KPI watch on production backend events, GA4 sessions and Google Ads spend: alerts only when a metric leaves its same-weekday band and the break isn't a known cause or tracking artifact. Silence means healthy."
---

# Daily KPI-Watch Loop

Catch breaks before they run for days. State: `state/bi-daily-kpi-watch.json` + `.log`.

| Part | Spec |
|---|---|
| **Cadence** | Daily (on demand while local; scheduled after deploy) |
| **Acts when** | A metric leaves its same-weekday band, or a backend event reads zero |
| **Stop / bail-out** | All in band → silent (log only). Money event or spend anomaly → escalate immediately. Bands need 8 same-weekday points; until then they're provisional and alerts say so. |
| **Output** | An alert with owner routing, or nothing |

## Before every run (all bi-* loops)

1. Read `CLAUDE.md`, `context/metrics.md` and this loop's `state/<loop>.json`.
2. Run `sql/readonly/source_freshness.sql`. Use only complete days: the backend replica's newest day is usually partial, and the trailing 72 hours are never judged. A source older than 8 days is **stale**: report "stale data — <source>", do not advance the cursor, halt if it is a required source.
3. BigQuery only (`databases-472111`, me-central2), read-only (`execute_sql_readonly`). Build numbers from `context/metrics.md` definitions and `sql/readonly/` queries; aggregated output only. `gold`/`silver`/`curated`/`reporting`/`dashboard_views`/`sama_mart` are suspended (tqa-012).
4. Not in BigQuery = **not configured** (Singular, Meta, TikTok, Snapchat, GA4 platform split). Name them under "Not covered"; never estimate them.
5. After the run: write the report to `reports/<yyyy>/W<ww>/`, update state, append one log line (plus `decision:` lines), commit.
6. Report the run live to the Command Center exactly as `docs/command-center.md` says: statuses and steps as they actually happen, never estimated.

## Loop body

1. **Latest complete day** per source (freshness query). Backend: registration, deposit, investment (counts; deposit amount per currency). GA4: sessions total + top channel groups. Google Ads: spend.
2. **Band check**: same weekday, trailing weeks from state (median ± 3×MAD; history from 2026-10-02 for backend, from first transfer day for GA4/Ads). Exact zero on a backend event = flag regardless.
3. **Classify**: real vs tracking artifact. One source moved while the backend held = tracking. A single channel at zero = tagging. Everything moved together = demand or outage.
4. **Known causes**: offerings (investment spikes are expected), Ramadan/Eid/National Day/Founding Day, salary days (~25th–28th), campaign launches, deploys. Note "possibly offering-driven" without asserting it.
5. **Route**: tracking → bi-tracking-health issue; funnel → bi-investor-funnel; spend → bi-paid-media-review; demand → weekly digest.

## State
`{"cursor": "<last day checked>", "bands": {...}, "active_anomalies": [{"id": "an-00x", "metric": "...", "since": "...", "status": "alerted"}]}`
Alert an ongoing anomaly once; post ✅ when it returns in band for 2+ days.

## Output (only when out of band)
```
⚠️ KPI watch — <date>
<metric>: <value> vs expected <band> (same weekday, n weeks)
Read: real / tracking artifact / unknown — evidence | Known causes ruled out: … | Routed to: …
```
