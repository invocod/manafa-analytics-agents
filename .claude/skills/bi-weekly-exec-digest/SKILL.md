---
name: bi-weekly-exec-digest
description: "The Monday heartbeat: full-funnel pulse of Manafa's AARRR metrics vs last week and vs plan, biggest movers flagged per stage, each tied to the loop or owner that should act, synthesizing the week's other loop outputs into one digest. Always runs."
---

# Weekly Marketing Review Loop

> **Data (2026-11-16): BigQuery only** (`databases-472111`, `me-central2`; see `CLAUDE.md` and `context/data-sources.md`). Backend counts = `manafa_financing.mi_analytics_events`; GA4 = `GA4` dataset; Google Ads = `google_ads` dataset; investor cohorts = `gold.fact_investor_journey`. CSV exports in `data/exports/` are ignored. Anything this skill mentions that isn't in BigQuery (Singular, Meta, TikTok, Snapchat) is "not configured". Read older "interim"/"CSV" wording below through this rule.

The standing full-funnel pulse — nothing drifts unnoticed. This loop is the **synthesizer**: it runs after bi-tracking-health, bi-channel-attribution, and bi-paid-media-review and folds their verdicts into one page. Read `CLAUDE.md` and `context/` first; state in `state/bi-weekly-exec-digest.json` + `.log`.

| Part | Spec |
|---|---|
| **Check cadence** | Weekly, Monday ~9am Riyadh (after the Monday loops) |
| **Acts when** | Always runs — it acts by flagging the week's notable movers |
| **Purpose** | One digest the team actually reads, with owners and next actions |
| **Stop / bail-out** | Manual disable + error-halt. On a source outage: report "stale data — <source>", never fabricate movement. |
| **Output** | One-page weekly digest → Slack + `reports/<yyyy>/<ww>/weekly-review.md` |

## Loop body

1. **Pull top-line funnel metrics** for last closed week vs the week before and vs plan (`context/manafa-marketing.md` targets): sessions, registrations, deposits, investments (interim ledger = GA4 key events until BigQuery; see `CLAUDE.md`), blended CAC if the Google Ads export is fresh.
2. **Fold in today's loop outputs** (read their state files and this week's reports): tracking-QA verdict, attribution readout headline, ads-check calls. If tracking-QA escalated, the review leads with that — every other number gets a "measurement suspect" badge.
3. **Flag the biggest mover per stage** — best and worst — with the trend-vs-noise check: a mover is a flag only if it's outside normal weekly variance (same computation discipline as the anomaly loop) or part of a 3-week run.
4. **Tie every flag to an owner or loop**: tracking → bi-tracking-health issue id; funnel step → bi-investor-funnel; paid → the ads-check call; demand/brand → human owner.
5. **Surface 1–2 experiment ideas** earned by this week's data (not generic ideas), as briefs for human triage.
6. **Session end**: write 1–3 decision lines to the run log; propose a Learnings row for `context/manafa-marketing.md` only when backed by a finished test or a 2+ week pattern — proposed in the digest for approval, never written silently.

## Self-check

Trend vs noise before every alarm. Same closed week in every number. Pending cohorts excluded from rates. Backend numbers define conversion counts everywhere in the digest.

## State

```json
{"cursor": "<last week reviewed>", "snapshots": {"2026-W46": {"sessions": 0, "reg": 0, "dep": 0, "inv": 0, "spend_sar": 0}}}
```

Snapshots make week-over-week deltas exact — never recompute last week from a platform that restates history.

## Digest format (Slack + reports/)

```
📅 Manafa weekly marketing review — week <ww>
Measurement: ✅ clean / ⚠️ <bi-tracking-health headline>
GA4 (analytics)    | Metric | This wk | Last wk | Δ |   ← GA4 numbers only
Singular (attribution) | Funnel by source | This wk | Last wk | Δ |   ← Singular numbers only
Biggest movers: ⬆ <stage: what, why we think, owner> / ⬇ <same>
Attribution headline: <one line from the readout>
Paid calls: <account: CALL> …
Experiments worth considering: 1) … 2) …
Proposed learnings (need approval): …
Stale/missing data: …
```
