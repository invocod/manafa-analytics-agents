# 📅 Manafa weekly digest — week W46 (9–15 Nov 2026)

**Measurement: 🚨 escalation open — the `gold` warehouse layer shows staging data (tqa-012).** Any report built on gold, reporting or dashboard_views may be wrong. Every number below comes from production backend events, GA4 or Google Ads directly.
Run: run-20261117-0603 (2026-11-17). Marks: **O** = Observed, **I** = Inferred. **Data** = queried numbers; **AI-generated** = interpretation for human review.

> Coverage: the backend copy ends 11 Nov, so backend KPIs cover **Mon–Wed (9–11 Nov)** and are compared with Mon–Wed of earlier weeks. GA4 and Google Ads cover the full week; GA4 restated 15 Nov (−11%) after first publication.

## Backend (truth) — Mon–Wed, Data
| Metric | W46 | W45 | vs W45 | 4-week median (W42–W45) | Read |
|---|---|---|---|---|---|
| Registrations | 256 | 286 | −10% | 316 | in range (200–362) |
| KYC completed | 402 | 541 | −26% | 522 | in range |
| Deposits | **235** | 356 | −34% | 332 | **below range** (254–482) |
| Deposit volume, SAR | **3.85M** | 7.59M | −49% | 8.11M | **below range** |
| Deposit volume, USD | 0 | 7,975 | — | 84,714 | below range |
| Investments | **4,113** | 3,204 | +28% | 2,316 | **above range** (1,264–3,204) |
| Investment volume, SAR | **15.2M** | 10.2M | +49% | 9.3M | **above range** |
| First investments | 25 | 137 | −82% | 28 | in range (W45 was a one-day batch) |
| Auto-invest enabled | 269 | 383 | −30% | 342 | in range |

## Funnel (14-day window, latest closed cohort: registrations 19–25 Oct), Data
KYC 69% · first deposit 7% · first investment 3% — web 37% / 2.4% / 1.4%; iOS 91% / 10% / 4.7%; Android 81% / 6.9% / 3.4%.
Early read (7-day, 26 Oct cohort): iOS deposits 14.6% and investments 7.4%, above range (Apple Pay first deposits up).

## GA4 (analytics), Data
Sessions 40,775 (9–15 Nov, restated), engaged 20,255. Channel mix is dominated by Direct and Unassigned (app sessions, tqa-001). No prior full week yet for comparison.

## Google Ads, Data
Spend 7,564 SAR · clicks 4,724 · claimed conversions 326 (9–13 Nov). Calls: iOS installs **HOLD**; Above 5Mn (B2B leads) **INVESTIGATE**; Android installs **INVESTIGATE**.

## Loop verdicts
- Tracking health: 🚨 escalation (tqa-012); 16 open issues, incl. new tqa-017 (investment event changed 26 Oct).
- Investor funnel: healthy; iOS activation up; worst leak web KYC (fx-01 awaiting approval).
- Paid media: 1 HOLD, 2 INVESTIGATE, nothing staged.
- KPI watch: silent.
- Campaign health: nothing ended; national_day_96 parked (no goals or spend data).
- Channel attribution: not run this week (backend attribution coverage ~5%, tqa-014).

## Biggest movers
- ⬆ **Investments +78% vs median (15.2M SAR)** — O: above range on Mon–Wed. I: possibly offering-driven (an offering launch typically produces this shape); not verified. Owner: demand / product.
- ⬇ **Deposits −29% (count) / −52% (SAR) vs median** — O: below range, second weekly decline (482 → 356 → 235). I: investors may be spending existing wallet balances on the offering rather than topping up; not verified. Owner: bi-investor-funnel + finance. Needs a third week (or the full W46) before it's a trend.
- ✅ **First-investment spike explained** — O: 2 Nov had 114 first investments, 103 of them auto-invest; other days 3–17. A one-off batch, not a flag change. Watch item closed.

## Experiments worth considering (AI-generated, for human triage)
1. **fx-01 web KYC handoff** (already staged): web KYC 28–37% vs 81–92% in the apps. Success: web KYC within 14 days ≥ 50% for 2 closed cohorts; guardrail: app KYC ≥ 85%.
2. **Make Apple Pay the default first-deposit option on iOS** (earned by the W44 early read: Apple Pay first deposits up from ~23 to 42 a week). Measure: iOS 7-day first-deposit rate on closed cohorts; success ≥ 12% for 2 cohorts; guardrail: deposit_failed share not up.

## Proposed learnings
None (no finished test or 2-week pattern yet).

## Stale / not covered
Backend replica ends 12 Nov (6 days old; stale at 8). gold suspended (tqa-012). Singular, Meta, TikTok, Snapchat, X not configured. GA4 has no web/app split. Total users not available.
