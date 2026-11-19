# 🩺 Investor funnel — cohorts closed through W44 (14d window), run 19 Nov

Run: run-20261119-0853 · bi-investor-funnel · started from the local Command Center
**Verdict: no change. Backend replica still frozen (data_end 16 Nov, 324,198 events, tqa-023), so no new cohort closed. Counts identical to run-20261118-1008/-2007/-2016 and cross-checked by an independent join query.**

| Step (W44 cohort, 14d, closed) | web | iOS | Android | Baseline (W41–W43 median, range) |
|---|---|---|---|---|
| Registrations | 277 | 349 | 102 | 221–295 / 307–384 / 105–138 |
| KYC 14d | 30.0% | 89.7% | 85.3% | web 32.1% (28.2–36.9) · iOS 90.6% (89.9–91.9) · Android 82.6% (81.0–84.8) |
| Deposit 14d | 2.2% (6) | **15.2%** (53) | 4.9% (5) | 2.7% (2.4–4.4) · 10.2% (9.8–11.7) · 6.9% (4.8–7.2) |
| Investment 14d | 1.1% (3) | **7.7%** (27) | 3.9% (4) | 1.4% (1.4–2.6) · 5.1% (4.7–6.8) · 3.4% (2.9–3.8) |

Early read, W45 (7d, closed at age ≥ 13; age 14): iOS 288 regs, KYC 87.5%, deposit 12.5%, investment 7.3%; Android 88 / 83.0% / 5.7% / 3.4%; web 258 / 34.5% / 1.9% / 1.2%.

- **Observed:** iOS deposit and investment above range (positive; driver Apple Pay first deposits, wf-01 closed-confirmed 18 Nov). Android cells < 200 entrants and web deposit/investment cells of 3–6 people are not judged.
- **Tracking ruled out:** funnel uses backend events only; heartbeat clean through 16 Nov (bi-tracking-health 19 Nov). tqa-013/007 affect GA4, not this table.
- **Worst leak:** web registration → KYC (30% vs ~90% iOS). Facts, hypotheses and missing data unchanged from `investor-funnel-2026-11-18.md`.
- **Proposed fix:** none new. fx-01 (web registration → KYC handoff) stays proposed, awaiting approval; open question for product: does a web KYC path exist?
- **Pending cohorts:** W45 (14d closes when data reaches 22 Nov; wf-02), W46, W47.

## Not covered
- GA4 platform split of the funnel (backend loop by rule 5); Meta/TikTok/Snapchat (not in BigQuery).
- Slack: not allowed in this run; this file is the deliverable.

_Decision support by the Manafa BI agent. Aggregates only._
