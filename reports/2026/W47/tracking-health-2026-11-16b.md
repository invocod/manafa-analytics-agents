# bi-tracking-health — week W46, follow-up run (run-20261116-1651)

**Verdict: 🚨 ESCALATION stands (tqa-012) + 1 new issue (tqa-017).**
Run: 2026-11-16 16:51 UTC. Marks: **O** = Observed, **I** = Inferred.

## Freshness
O: backend 300,388 events ending 2026-11-12 (partial), GA4 to 2026-11-15, Google Ads to 2026-11-15: all **unchanged** since run-20261116-1530. Only `gold` changed (rebuilt 2026-11-16 15:30 UTC).
Checks on unchanged data were not re-run; their results from run-20261116-1530 stand (heartbeat clean; tqa-007, tqa-013, tqa-003/004/015, tqa-016, naming).

## Ledger integrity: tqa-012 still broken after the rebuild
| Week | gold | staging | production |
|---|---|---|---|
| 12 Oct | 2,120 / 24.3M SAR | 4,184 / 39.8M | 4,025 / 19.2M |
| 19 Oct | 349 / 1.2M | 686 / 1.4M | 8,414 / 29.1M |
| 26 Oct | 140 / 2.9M | 88 / 0.25M | 3,613 / 13.7M |
| 2 Nov | **161 / 238,000** | **161 / 238,000** | 4,717 / 17.4M |

O: gold's newest profile is still 610,975. The escalation stands.

## New: tqa-017 [MED] — investment_completed changed on 26 Oct (backend, all platforms)
O (daily, investment_completed):
- `payment_method`: `opportunities.ewallet` through 25 Oct; both values on 26 Oct; `wallet` only from 27 Oct.
- Platform of auto-invest investments: all `web` before (22 Oct: 3,234 of 3,234), the user's device after (28 Oct: 35 of 606 on web).
- Web investments: 6,455 (W43) → 257 (W44); iOS 1,378 → 2,426.
- O: `payment_method` is not a parameter of `investment_completed` in Event Standard v2.1.
- Impact: investment counts by event platform aren't comparable across 26 Oct. Cohort funnels are unaffected (they use the registration platform).
- Owner: backend + standard owner. Next check: backend changelog for 26 Oct; decide the intended platform for server-executed (auto-invest) investments.

## Correction to bi-investor-funnel (run-20261116-1635)
The `payment_method` change it flagged is this backend change, **not an iOS release**. Its iOS Apple Pay deposit uplift stands (backend deposits); the cause is unknown.
