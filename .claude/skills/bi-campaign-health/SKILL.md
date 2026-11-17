---
name: bi-campaign-health
description: "Campaign health and postmortem: when a Manafa campaign (offering launch, promo, seasonal or creator push) concludes, measure results vs goals on backend data, capture lessons and reusable assets. On demand (/bi-campaign-health <campaign>) or when the digest notices a campaign ended."
---

# Campaign-Health Loop

Make each campaign teach the next one. State: `state/bi-campaign-health.json` + `.log`.

| Part | Spec |
|---|---|
| **Cadence** | On demand / on campaign end |
| **Acts when** | A concluded campaign has no postmortem in state |
| **Stop / bail-out** | Inside its conversion lag (14d after end) → set a ready date in state and wait. |
| **Output** | `reports/postmortems/<campaign>.md` + summary + proposed learnings |

## Before every run (all bi-* loops)

1. Read `CLAUDE.md`, `context/metrics.md` and this loop's `state/<loop>.json`.
2. Run `sql/readonly/source_freshness.sql`. Use only complete days: the backend replica's newest day is usually partial, and the trailing 72 hours are never judged. A source older than 8 days is **stale**: report "stale data — <source>", do not advance the cursor, halt if it is a required source.
3. BigQuery only (`databases-472111`, me-central2), read-only (`execute_sql_readonly`). Build numbers from `context/metrics.md` definitions and `sql/readonly/` queries; aggregated output only. `gold`/`silver`/`curated`/`reporting`/`dashboard_views`/`sama_mart` are suspended (tqa-012).
4. Not in BigQuery = **not configured** (Meta, TikTok, Snapchat platform data, GA4 platform split). Name them under "Not covered"; never estimate them. **Exception: Singular** is read from its Google Sheet per `context/singular-sheet.md` (validate first; own "Singular (attribution)" section; never blended).
5. After the run: write the report to `reports/<yyyy>/W<ww>/`, update state, append one log line (plus `decision:` lines), commit.
6. Report the run live to the Command Center exactly as `docs/command-center.md` says: statuses and steps as they actually happen, never estimated.

## Loop body

1. **Define window and goals** (brief if one exists; otherwise reconstruct from campaign names/UTMs and ask for goals in open questions).
2. **Results over window + 14-day lag tail**: spend (Google Ads; other platforms not configured), GA4 traffic by the campaign's UTMs, backend conversions attributed to the campaign via `acquisition_campaign` / `last_campaign` (state attribution coverage, tqa-014).
3. **Efficiency** with matched windows: full-window spend ÷ full-window+lag backend conversions; state it explicitly.
4. **Worked / didn't / why**, supported by data; correlation vs cause labelled. Compare to a matched non-campaign baseline period.
5. **Reusable assets** with evidence; **feed forward** experiments and proposed Learnings (human-approved).

## Output
```
🧾 Campaign health — <campaign>
Goal → Result | Spend X → reg A / dep B / inv C (backend; attributed coverage _%)
Worked … | Didn't … | Unknown … | Reusable … | Proposed learnings … | Open questions …
```
