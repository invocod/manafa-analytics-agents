# 📅 Manafa Weekly Marketing Review — covering week 45 (Mon Nov 2 – Sun Nov 8)

**Measurement: ⚠️ usable with care.** Money events (deposits, investments) are verified across GA4↔Singular. Registration/KYC counts carry a **measurement-suspect badge** (tqa-007: GA4 fires ~1.6–1.9× Singular on them; cause unresolved). This digest's numbers are Singular all-platform counts (GA4 exports lack a weekly split). 7 tracking issues open.

## Funnel — W45 vs W44

| Funnel | W45 (Nov 2–8) | W44 (Oct 26–Nov 1) | Δ | Plan |
|---|---|---|---|---|
| Sessions (Singular) | 23,274 | 29,519 | −21% | — (baseline mode) |
| Registrations ⚠️ | 556 | 678 | −18% | — |
| KYC completed ⚠️ | 452 | 539 | −16% | — |
| Deposits ✅ | 592 | 853 | −31% | — |
| Investments ✅ | 4,007 | 3,226 | +24% | — |
| Blended CAC | n/a | n/a | — | no spend data (Google Ads export missing) |

**Base-effect warning (self-check):** W44 contains the salary-days surge (Oct 26–28: registration peak 150/day, deposit peak 236/day — known cause). The W45 declines in sessions/registrations/deposits are measured against that inflated base; with only 2 closed weeks of history, **none of the drops qualifies as a trend yet**. Next salary window ~Nov 25 will give the clean comparison.

## Biggest movers
- ⬆ **Investments +24%** (4,007) — offering-driven, Manafa's expected shape. Owner: none needed; the anomaly loop watches the daily band.
- ⬇ **Deposits −31%** (592) — most plausibly the salary-week base effect (known cause), **watch, don't act**. If W46 lands below ~600 again with no offering explanation, route to funnel-health as a regression candidate. Owner: this loop, next run.
- 🚫 Not movers: App Install "+61,000%", investment_started, registration_started — these events only began being tracked ~Oct 30–Nov 2 (tqa-008). Excluded from week-over-week math; baselines start Nov 3.

## Loop verdicts folded in
- **tracking-qa:** ISSUES(7) — headline: identity events (reg/KYC) disagree GA4↔Singular beyond the explainable band (tqa-007); UTM convention violations and 79% direct share open (tqa-001/003/004).
- **attribution:** paid drives ~40% of attributed registrations — TikTok 13% + Snapchat 8% at ~99% KYC completion, **invisible in GA4**; budget calls blocked on the Google Ads export + unmeasured reg→deposit lag.
- **weekly-ads-check:** INVESTIGATE — stale data (no Google Ads export ever provided; account unreviewable).
- **analytics-anomaly:** latest day all in band; one artifact filed (tqa-008).

## Experiments worth considering (for human triage — earned by this week's data)
1. **Self-reported attribution at registration** ("How did you hear about us?", pick-list + free text): 57–96% of conversions are unattributed; this is the cheapest instrument that illuminates the direct/dark mass. Measure: % of new registrations with an answer, channel mix vs Singular's after 4 weeks.
2. **Registration-completion audit → test**: GA4 shows registration_started 9,652 vs completed 3,010 (~31% completion, 22-day window). First run funnel-health to verify the step (and reconcile with tqa-007), then test the biggest friction point in the signup flow.

## Proposed learnings
None promotable yet (rule: 2+ runs/windows of evidence). One candidate pending a second window: *"GA4 alone cannot evaluate app acquisition — paid social is 0.18% of GA4 sessions but 21% of Singular-attributed registrations."*

## Stale / missing data
Google Ads export (spend, CAC, ads-check — **the single most valuable missing file**) · GA4 weekly/channel split for key events (or BigQuery) · reg→deposit lag unmeasured · events tracked only since ~Nov 2 excluded (installs, *_started).

## Next actions
| Action | Owner |
|---|---|
| Drop Google Ads export → unblocks ads-check, CAC, over-claim check | Amir / media |
| GA4 event × platform explore → closes tqa-007 | Amir / analytics |
| Confirm what enabled install/*_started tracking ~Oct 30–Nov 2 → closes tqa-008 | app eng |
| Fix LinkedIn/paid-social UTM templates (tqa-003) | link builders |
| Decide on self-reported attribution question | marketing lead |
