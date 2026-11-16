# bi-investor-funnel — cohorts closed through W43 (14-day) / W44 (7-day early read)

**Verdict: HEALTHY, 1 positive mover (iOS activation up); worst leak unchanged (web KYC, fx-01 awaiting approval).**
Run: 2026-11-16 (run-20261116-1635), Riyadh tz. Source: production backend events (`sql/readonly/investor_funnel_cohorts_prod.sql`).
Data ends 2026-11-11 (last complete day): no new backend data since the 16 Nov re-baseline, so no new cohort closed on the 14-day window.
Marks: **O** = Observed, **I** = Inferred.

## Funnel (7-day early read, W44 = registrations 26 Oct – 1 Nov)
| Platform | Registrations | KYC 7d | Deposit 7d | Investment 7d | vs W41–W43 range |
|---|---|---|---|---|---|
| Web | 277 | 30.0% | 2.2% | 1.1% | all in range |
| iOS | 349 | 89.7% | **14.6%** | **7.4%** | deposit above 9.0–9.8%; investment above 3.6–5.9% |
| Android | 102 | 85.3% | 4.9% | 3.9% | in range (n too small to flag) |
| All | 728 | 66.3% | 8.5% | 4.5% | KYC dip = platform mix (web share 38%) |

14-day baselines (closed cohorts W41–W43): web KYC 28–37%, iOS 90–92%, Android 81–85%; deposits web 2–4%, iOS 10–12%, Android 5–7%.

## Findings
- O: W44 registrations 728, matching the weekly KPI count (cross-check passed).
- O: iOS first deposits within 7 days rose to 51 (42 Apple Pay, 7 bank transfer, 2 card), against about 33 a week in W41–W43 (about 23 Apple Pay a week).
- O: 7 of 26 iOS first investments in W44 were auto-invested (1 in W41–W43 combined).
- O: iOS first investments switched `payment_method` from `opportunities.ewallet` (W41–W43) to `wallet` (W44): a payload change, passed to bi-tracking-health.
- I: ~~an iOS release in late October is a plausible cause~~ **Corrected by bi-tracking-health (run-20261116-1651):** the `payment_method` change was a backend change on all platforms on 26 Oct (tqa-017), not an iOS release. The Apple Pay deposit uplift is real (backend deposits); its cause is unknown, possibly offering-driven.
- O: the worst leak is unchanged: web KYC 30% vs 85–90% in the apps.

## Decision
No new fix proposed: fx-01 (web KYC handoff) is staged and awaiting a product decision; it still targets the worst leak.

## Watch items
- Confirm the iOS uplift on the 14-day window when data reaches 2026-11-15 (W44 closes).
- Ask product/marketing what changed for iOS Apple Pay deposits in late October.

## Not covered
Channel split of the funnel (backend attribution coverage ~5%, tqa-014); Singular installs (not in BigQuery).
