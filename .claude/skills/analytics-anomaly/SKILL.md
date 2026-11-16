---
name: analytics-anomaly
description: "Daily anomaly watch on Manafa's key metrics (sessions, registrations, deposits, investments, spend). Alerts only when a metric breaks its expected band and the break isn't a known cause or tracking artifact. Silence means healthy."
---

# Analytics-Anomaly Loop

Catch anything breaking — good or bad — before it runs for days. Read `CLAUDE.md` and `context/` first; state in `state/analytics-anomaly.json` + `.log`.

> **Data (2026-11-16): BigQuery only** (`databases-472111`, `me-central2`; see `CLAUDE.md` and `context/data-sources.md`). Backend counts = `manafa_financing.mi_analytics_events`; GA4 = `GA4` dataset; Google Ads = `google_ads` dataset; investor cohorts = `gold.fact_investor_journey`. CSV exports in `data/exports/` are ignored. Anything this skill mentions that isn't in BigQuery (Singular, Meta, TikTok, Snapchat) is "not configured". Read older "interim"/"CSV" wording below through this rule.

| Part | Spec |
|---|---|
| **Check cadence** | Daily (morning, Riyadh time) |
| **Acts when** | A tracked metric leaves its expected band (beyond normal variance for that weekday) |
| **Purpose** | Early detection; route to the right owner/loop |
| **Stop / bail-out** | All in-band → silent (log only, no Slack post). **Revenue (deposit/investment) or spend anomaly → escalate immediately.** |
| **Output** | An anomaly alert with owner routing, or nothing |

## Loop body

1. **Pull yesterday** (complete day, Riyadh tz): GA4 sessions (total + top 5 channels), backend `registration_completed`, `deposit_success`, `investment_completed`. Spend per platform only if a fresh export exists — never estimate spend.
2. **Band check per metric**: compare against the same weekday over the trailing 8 weeks (median ± 3×MAD, computed from row-level data — compute, don't eyeball). Also flag exactly-zero on any backend event regardless of bands.
3. **Classify each breach**: real event vs tracking artifact. Artifact tells: one source moved while others held (GA4 dropped but backend steady = tracking, not demand); a single channel went to zero (tagging/integration); everything moved together (real demand or an outage).
4. **Known-cause check**: offerings calendar (a hot offering spikes investments — expected shape, not an anomaly), Ramadan/Eid/National Day, salary days, campaign launches, deploys. A breach with a named known cause is logged, not alerted.
5. **Route**: tracking artifact → tracking-qa loop (file into its open issues); funnel move → funnel-health; spend/platform move → weekly-ads-check; genuine demand shift → weekly review flag.

## Self-check

Is yesterday actually complete in every source (GA4 intraday lag)? If a source is late, compare only the sources that are complete and say which were skipped. Never alert on a metric whose source was stale.

## State (dedupe is the whole game)

```json
{"cursor": "2026-11-10", "active_anomalies": [{"id": "an-034", "metric": "sessions:snapchat", "since": "2026-11-08", "status": "alerted"}]}
```

An ongoing anomaly is alerted **once**, then updated silently in state until it resolves (post a ✅ resolution note when it returns in-band after 2+ days). Never re-alert the same ongoing anomaly daily.

## Slack output (only when something's out of band)

```
⚠️ Anomaly — <date>
<metric>: <value> vs expected <band> (same-weekday, 8w)
Read: real / tracking artifact / unknown — evidence
Known causes ruled out: <list>
Routed to: <owner/loop>
```
