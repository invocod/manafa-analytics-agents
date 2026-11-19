# 📅 Manafa weekly digest — week 46 (9–15 Nov 2026), run 19 Nov

Run: run-20261119-0853 · bi-weekly-exec-digest · last in the run, after bi-tracking-health, bi-investor-funnel, bi-channel-attribution, bi-paid-media-review and bi-daily-kpi-watch.
**No new week to report.** The backend replica is still frozen (324,198 events, data to 16 Nov, tqa-023), so W47 can't be read. Every W46 figure was re-queried and matches `weekly-exec-digest-2026-11-18.md`, which stays the full W46 digest. Only change: Google Ads claims are now read for the full week.

```
📅 Manafa weekly digest — week 46
Measurement: 🚨 tqa-012 (gold = staging) stands; production ledger clean; replica frozen since 17 Nov (stale on 20 Nov, tqa-023)
Backend (truth) | Metric          | This wk | Last wk | 4-wk median | Δ vs last |
                | Registrations   | 550     | 634     | 681         | −13%  (below range)
                | KYC completed   | 831     | 1,118   | 1,134       | −26%  (below range)
                | Deposits        | 457 / 5.75M SAR | 646 / 10.87M SAR | 616 / 15.17M SAR | −29% / −47%  (below range)
                | Investments     | 6,396 / 22.76M SAR | 4,717 / 17.45M SAR | 4,371 / 18.31M SAR | +36% / +30%  (in range)
                | First investments | 60    | 171*    | 65          | (in range)
                | Auto-invest enabled | 574 | 791     | 784         | −27%  (below range)
Funnel (14d, closed cohort W44): KYC 30.0 / 89.7 / 85.3% · deposit 2.2 / 15.2 / 4.9% · invest 1.1 / 7.7 / 3.9% (web / iOS / Android)
GA4 (analytics) | sessions 24,755 (engaged 20,272), flat vs W45 | Direct 72.0%, Organic Search 11.0%, Unassigned 5.5%, Cross-network 5.3%, Paid Search 3.4%
Command Center (GA4) covers: reg 79.5% · KYC 47.5% · dep 90.6% · inv 84.5% of backend (not GA4 READY)
Google Ads | spend 9,154.68 SAR, 4,758 clicks | claimed conv 702 (first open 529, kyc_completed 143 doubled, B2B form 30)
Movers: ⬇ iOS registrations 4th weekly fall 384→226 (growth / perf. marketing) · ⬇ deposits 3rd fall 888→646→457 (bi-investor-funnel + Finance) · ⬆ investments +46% vs median, offering-driven (investments / product)
Paid calls: Google Ads FIX (pm-fix-001 staged) · TikTok iOS INVESTIGATE · X iOS INVESTIGATE
Experiments: fx-01 web KYC handoff (staged) · Apple Pay default first deposit on iOS
Proposed learnings: iOS first-deposit uplift = Apple Pay (final when W45 closes on 14 days, data to 22 Nov)
Not covered / stale: gold (tqa-012); W47 (replica frozen); Meta/TikTok/Snapchat platform data; Singular conversion events
```
\*W45 holds the 2 Nov one-day auto-invest batch.

## Re-checked this run (Observed)
- Backend W46 vs W45 re-queried: reg 550 / 634, KYC 831 / 1,118, deposits 457 / 646 (5,754,086.82 / 10,870,946.36 SAR), investments 6,396 / 4,717 (22,764,000 / 17,448,000 SAR), first investments 60 / 171, auto-invest enabled 574 / 791. Identical to the W46 snapshot.
- Funnel, attribution, paid-media and KPI-watch results are from this run's loop reports (all 19 Nov, `reports/2026/W47/`).

## Loop verdicts (this run)
- **Tracking health:** 🚨 escalation tqa-012 stands; 0 new issues; none fixed; GA4 readiness not yet (lowest identity_verified 27.3%).
- **Investor funnel:** no change; cursor W44; fx-01 awaiting approval.
- **Channel attribution:** no budget shift (confidence low); TikTok iOS down at flat cost.
- **Paid media:** Google Ads FIX; TikTok iOS and X iOS INVESTIGATE; W46 claims now full-week (702).
- **Daily KPI watch:** silent; 16–17 Nov (including the large 17 Nov deposit) judged on the 20 Nov run.
- **Campaign health:** runs after this digest.

## Not covered / stale
- `gold` suspended (tqa-012). Backend replica frozen (tqa-023), so W47 can't be read until it moves. Meta, TikTok and Snapchat platform data not in BigQuery; Singular has no conversion events.
- Slack: not allowed in this run; this file is the deliverable.

_Decision support by the Manafa BI agent. Aggregates only; for review by a named owner before any action._
