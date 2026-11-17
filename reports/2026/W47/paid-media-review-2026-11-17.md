# bi-paid-media-review — week W46 (9–15 Nov 2026)

**Calls: Google Ads — 2 × INVESTIGATE, 1 × HOLD.** Meta, TikTok, Snapchat, X: not configured (not in BigQuery).
Run: run-20261117-0603 (2026-11-17). Spend and traffic: full week 9–15 Nov. Conversions judged 9–13 Nov only (72-hour rule). Ranges are **provisional**: Google Ads history starts 7 Nov. Marks: **O** = Observed, **I** = Inferred.

## Account: Google Ads (customer 3343082801, SAR) — spend 7,564 SAR
| Campaign | Spend | Clicks | CTR | CPC | Claimed conv (9–13 Nov) | Claimed CPA | Call |
|---|---|---|---|---|---|---|---|
| Minto \| App promotion - IOS \| App installs | 2,613 | 2,429 | 6.96% | 1.08 | 145 | 13.0 | **HOLD** |
| Minto \| Above 5Mn (B2B leads, Search) | 3,693 | 808 | 6.78% | 4.57 | 20 | 124.0 | **INVESTIGATE** |
| Minto \| App installs - Android | 1,258 | 1,487 | 1.31% | 0.85 | 161 | 5.6 | **INVESTIGATE** |

Cross-check: W46 spend 7,564 SAR matches the W46 snapshot in state (7,563.18, rounding).

### iOS installs — HOLD
- O: spend 356–385 SAR/day (variation 3%), CTR 5.7–8.6%, no break. Claimed conversions are iOS First open (153 by action).
- I: nothing named to fix. Installs can't be verified (Singular not in BigQuery); iOS activation is up in the funnel (wf-01), so no reason to change.

### Above 5Mn (B2B borrower leads) — INVESTIGATE
- O: only conversion is a GA4-imported web form success (`above-5-b2b-b2g-ar-success`), 20 claimed leads 9–13 Nov.
- O: daily spend swung 258 SAR (13 Nov) to 778 SAR (15 Nov), against ~550/day earlier.
- O: ads land on `manafa.sa/lpg` with `utm_campaign=Minto_Manafa_B2B` (uppercase and underscores break `context/utm-convention.md`); sibling campaigns' ads carry no UTMs.
- Not in scope of the investor funnel: B2B leads have no ledger in BigQuery (gold.fact_lead suspended, tqa-012).
- **Settling check:** B2B lead count from the CRM for 9–13 Nov, compared with the 20 claimed.

### Android installs — INVESTIGATE
- O: steady spend (165–203 SAR/day), CTR 0.9–1.7%.
- O: the conversion-action breakdown (first open 225 + GA4-imported kyc_completed 98 = 323) is about 2× the campaign total (161) for 9–13 Nov, so it can't be read from this data whether kyc_completed (doubled in GA4, tqa-007) counts for bidding. This weakens tqa-016's inference that it is Primary.
- **Settling check:** Google Ads → Goals → Conversions → Summary: Primary flags for the Android actions (tqa-016).

## Staged for approval
None this week (both INVESTIGATE calls need their settling check first).

## Missing data
Meta, TikTok, Snapchat, X spend (Phase 2, B4); backend conversions by campaign (tqa-014); installs (Singular); B2B lead ledger.
