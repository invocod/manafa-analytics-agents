---
name: bi-investor-funnel
description: "Weekly funnel loop combining signup-funnel-leak and onboarding drop-off: step-by-step conversion from visit → registration → KYC → deposit → investment, regression detection vs baseline, one prioritized fix proposal with a measurement plan."
---

# Funnel-Health Loop

Find the biggest leak between first visit and first investment, every week. Read `CLAUDE.md` and `context/` first; state in `state/bi-investor-funnel.json` + `.log`.

> **Data (2026-11-16): BigQuery only** (`databases-472111`, `me-central2`; see `CLAUDE.md` and `context/data-sources.md`). Backend counts = `manafa_financing.mi_analytics_events`; GA4 = `GA4` dataset; Google Ads = `google_ads` dataset; investor cohorts = `gold.fact_investor_journey`. CSV exports in `data/exports/` are ignored. Anything this skill mentions that isn't in BigQuery (Singular, Meta, TikTok, Snapchat) is "not configured". Read older "interim"/"CSV" wording below through this rule.

| Part | Spec |
|---|---|
| **Check cadence** | Weekly (Tuesday — after Monday's tracking-QA confirms the data is trustworthy) |
| **Acts when** | A funnel step regresses vs its baseline, or a step's drop-off exceeds its historical band |
| **Purpose** | Keep signup converting as the site changes; find the worst activation leak |
| **Stop / bail-out** | Sample too small for a step → widen the window to 2–4 weeks or skip that step, and say so. No regression and no test-worthy idea → log "healthy", no post. |
| **Output** | One prioritized fix/experiment brief with a measurement plan |

## Loop body

1. **Pull step-by-step conversion** for the last closed week, cohorted by entry week, Riyadh tz:
   - Signup flow: sessions → signup started → `registration_completed` (GA4 funnel + backend count as denominator check)
   - Activation flow: `registration_completed` → KYC/account opened → `deposit_success` → `investment_completed` (backend)
2. **Matched observation windows** (non-negotiable): a registration cohort still inside the typical registration→deposit lag (see `context/manafa-marketing.md`) is **pending**, not failed. Only closed cohorts enter rates. State which cohort weeks each rate uses.
3. **Compare each step** to its trailing 8-week baseline (same cohort definition). Flag regressions beyond normal variance; check deploy/campaign timing against the regression date.
4. **Rule out tracking breakage first** (cross-check backend vs GA4 at the regressed step; consult bi-tracking-health's open issues) before declaring a real drop.
5. **Diagnose the worst leak**: segment the regressed step by device, channel, new-vs-returning, offering availability. Separate facts from hypotheses.
6. **Propose exactly one fix or experiment**: what to change, expected effect, how to measure it (metric, cohort, window, success threshold). Check state so you don't re-propose something already staged, or touch a step with a fix still in its measurement window.

## Self-check

Enough users through each step this week for the rate to be meaningful? (Rule of thumb: flag nothing on <200 cohort entrants at the step without widening the window.) Is the "regression" an offering-mix effect — low investment conversion because no attractive offering was open?

## State

```json
{"cursor": "<last cohort week closed>", "baselines": {"reg_to_deposit": 0.0}, "proposed_fixes": [{"id": "fx-07", "step": "kyc", "status": "staged", "measure_until": "2026-12-01"}], "in_flight": []}
```

Measure a shipped fix's effect before re-touching its step.

## Slack output

```
🩺 Funnel health — week <ww>
| Step | Rate (closed cohorts) | Baseline | Δ |
Worst leak: <step> — facts / hypotheses / missing data
Proposed fix: <one> — measurement plan: <metric, window, threshold>
Pending cohorts excluded: <weeks>
```
