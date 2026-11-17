---
name: bi-investor-funnel
description: "Weekly investor-funnel loop on production backend cohorts: registration → identity/KYC → first deposit → first investment by registration week and platform, regression vs baseline on closed cohorts only, one prioritized fix with a measurement plan."
---

# Investor-Funnel Loop

Find the biggest leak between registration and first investment. State: `state/bi-investor-funnel.json` + `.log`.

| Part | Spec |
|---|---|
| **Cadence** | Weekly (Tuesday, after bi-tracking-health) |
| **Acts when** | A closed cohort's step rate leaves its baseline band, or a platform gap widens |
| **Stop / bail-out** | bi-tracking-health escalated on a funnel event → mark the step "measurement suspect" and don't diagnose it. < 200 cohort entrants on a step → widen to 2–4 weeks or skip. Nothing new → log "healthy". |
| **Output** | Funnel table + one fix/experiment brief with a measurement plan |

## Before every run (all bi-* loops)

1. Read `CLAUDE.md`, `context/metrics.md` and this loop's `state/<loop>.json`.
2. Run `sql/readonly/source_freshness.sql`. Use only complete days: the backend replica's newest day is usually partial, and the trailing 72 hours are never judged. A source older than 8 days is **stale**: report "stale data — <source>", do not advance the cursor, halt if it is a required source.
3. BigQuery only (`databases-472111`, me-central2), read-only (`execute_sql_readonly`). Build numbers from `context/metrics.md` definitions and `sql/readonly/` queries; aggregated output only. `gold`/`silver`/`curated`/`reporting`/`dashboard_views`/`sama_mart` are suspended (tqa-012).
4. Not in BigQuery = **not configured** (Meta, TikTok, Snapchat platform data, GA4 platform split). Name them under "Not covered"; never estimate them. **Exception: Singular** is read from its Google Sheet per `context/singular-sheet.md` (validate first; own "Singular (attribution)" section; never blended).
5. After the run: write the report to `reports/<yyyy>/W<ww>/`, update state, append one log line (plus `decision:` lines), commit.
6. Report the run live to the Command Center exactly as `docs/command-center.md` says: statuses and steps as they actually happen, never estimated.

## Loop body

1. **Pull cohorts** (`investor_funnel_cohorts_prod.sql`): by `cohort_week` × `reg_platform`. Standard window **14 days** (closed when `cohort_age_days >= 20`); 7d early read (closed at >= 13). Open cohorts are **pending**.
2. **Rates**: kyc, deposit, investment within the window ÷ registrations, per platform and total. Never use `kyc_completed` event counts as a funnel step (63% are existing users); cohort only.
3. **Compare** each closed cohort to the trailing baseline in state (median and range of prior closed cohorts, same platform). Flag moves outside the range or 3-cohort runs in one direction.
4. **Rule out tracking first**: check bi-tracking-health open issues touching the step (e.g. tqa-013 for web).
5. **Diagnose the worst leak**: split by platform (and by first-investment vs auto-invest where relevant). Separate facts / hypotheses / missing data. Offering availability can depress investment rates: note "possibly offering-driven" without asserting it.
6. **Propose exactly one fix or experiment** with metric, cohort, window, success threshold and guardrail. Don't re-propose a staged fix; measure a shipped fix before touching its step again.

## Self-check
Only closed cohorts in rates? Same window everywhere? Enough entrants? Offering-mix effect?

## Output
```
🩺 Investor funnel — cohorts closed through <week> (14d window)
| Step | Rate | Baseline | Δ | web / iOS / Android |
Worst leak: <step> — facts / hypotheses / missing data
Proposed fix: <one> — measure: <metric, cohort, window, threshold, guardrail>
Pending cohorts: <weeks>
```

## State
`{"cursor": "<last closed cohort week>", "baselines": {...}, "proposed_fixes": [...], "in_flight": []}`
