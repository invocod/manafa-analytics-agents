# 🔻 Investor funnel — W44 cohort closed (14-day), run 18 Nov

Run: run-20261118-1008 · bi-investor-funnel · source: production backend (`investor_funnel_cohorts_prod.sql`), data_end 16 Nov
**Verdict: iOS deposit and investment are ABOVE their band on a closed cohort. This is a positive break, now confirmed on 14 days (watch wf-01) and holding for a second week on 7 days. Cause partly identified: Apple Pay first deposits. Nothing is broken; web KYC (fx-01) remains the worst leak.**

## W44 cohort (registered 26 Oct – 1 Nov), 14-day window, closed
| Platform | Registrations | KYC 14d | Deposit 14d | Invest 14d | vs band (W41–W43) |
|---|---|---|---|---|---|
| iOS | 349 | 89.7% (313) | **15.2% (53)** | **7.7% (27)** | deposit above [7.1–13.2%], invest above [3.4–6.7%] |
| Android | 102 | 85.3% (87) | 4.9% (5) | 3.9% (4) | in band (small cohort) |
| Web | 277 | 30.0% (83) | 2.2% (6) | 1.1% (3) | in band |

## W45 cohort (2–8 Nov), 7-day early read (14 days closes when data reaches 22 Nov)
| Platform | Registrations | KYC 7d | Deposit 7d | Invest 7d |
|---|---|---|---|---|
| iOS | 288 | 87.5% | **12.5%** (band 6.6–12.2%, above) | 7.3% (band to 8.3%, in) |
| Android | 88 | 83.0% | 5.7% | 3.4% |
| Web | 258 | 34.5% | 1.9% | 1.2% |

## Why iOS is up
**Observed:** iOS first deposits within 14 days by payment method:

| Cohort | Apple Pay | Card + bank transfer |
|---|---|---|
| W41 | 23 | 12 |
| W42 | 26 | 10 |
| W43 | 27 | 12 |
| W44 | **42** | 11 |

The whole uplift is Apple Pay; other methods are flat.

**Not the cause:** tqa-017, the 26 Oct backend change, renamed `payment_method` on all platforms. Android and web don't move, so this isn't a relabelling.

**Inferred (unverified):** something changed for iOS Apple Pay deposits in late October: placement, default, limits or a campaign. Product and marketing should say what shipped.

## Worst leak (unchanged)
- Web registration → KYC: 30.0% on W44 vs 85–90% in the apps.
- **fx-01** (web KYC handoff) is still awaiting approval and product's answer on whether a web KYC path exists.

## Decisions
- Cursor moves to **2026-W44**.
- **wf-01 closes as confirmed**, a positive change of unknown cause. New watch **wf-02**: confirm on W45's 14-day read (needs data to 22 Nov) and find out what changed for iOS Apple Pay.
- No new fix proposed.

## Data notes
- Backend replica complete through 16 Nov. It refreshes in batches (tqa-023), so the next cohort may wait on a refresh.
- `kyc_completed` is a cohort step only. Event counts include existing profiles.
