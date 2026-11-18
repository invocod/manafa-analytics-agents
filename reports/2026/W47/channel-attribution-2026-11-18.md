# 🧭 Channel attribution — W46 (9–15 Nov 2026), full week, run 18 Nov

Run: run-20261118-1008 · bi-channel-attribution. Replaces the Mon–Wed read from 17 Nov now that the backend covers the full week.
**Verdict: no budget shift (confidence low).** The backend can tie only 1–4% of conversions to a channel. Each source below reports in its own section; sources are never added or blended.

## 1. Backend ledger: conversion truth (W46 full week, Riyadh)
| | W46 | 4-week median (W42–W45) | vs median | Band |
|---|---|---|---|---|
| Registrations | 550 | 681 | −19% | in |
| Deposits (count) | 457 | 616 | −26% | in |
| Deposits (SAR) | 5.75M | 15.17M | −62% | in (very wide: amounts are lumpy) |
| — deposits under 500k SAR | 4.82M | 6.22M | −22% | in |
| Investments (count) | 6,396 | 4,371 | +46% | in |
| Investments (SAR) | 22.76M | 18.31M | +24% | in |

- **Observed:** deposits fell three weeks running by both count and SAR.

  | Week | Deposits | SAR |
  |---|---|---|
  | W44 | 888 | 12.1M |
  | W45 | 646 | 10.9M |
  | W46 | 457 | 5.75M |

  Most of the SAR drop is large deposits (≥500k SAR). These were 4–6 a week in October and 1 in W46. Smaller deposits fell 22%.
- **Observed:** investments were well above the median while deposits fell.
- **Inferred, not verified:** investors are spending wallet balances on the current offerings rather than topping up. Finance should confirm.
- All amounts are SAR; no non-SAR money events this week.

## 2. Backend attribution coverage (tqa-014)
| Event | Share with acquisition_source | Baseline (W41–W45) |
|---|---|---|
| registration_completed | 3.8% | 4.1–5.9% (just below) |
| deposit_success | 1.3% | 1.0–1.8% |
| investment_completed | 1.4% | 0.9–1.7% |

Attributed events W46: google / cpc reg 16, dep 5, inv 74 · x / paid_social inv 13 · chatgpt.com reg 5.
That's too few to rank channels. ISQ-6054 / 6055 (attribution at registration) and ISQ-6057 (real last touch) are the fixes.

## 3. GA4 (product analytics), W46 full week
| Channel | New users, first touch | Share | Sessions (session channel) | Share |
|---|---|---|---|---|
| Direct | 2,739 | 49.7% | 18,938 | 46.5% |
| Organic Search | 1,066 | 19.3% | 2,874 | 7.1% |
| Cross-network (PMax) | 588 | 10.7% | 1,525 | 3.7% |
| Paid Search | 515 | 9.3% | 918 | 2.3% |
| Referral | 268 | 4.9% | 373 | 0.9% |
| Organic Social | 227 | 4.1% | 253 | 0.6% |
| AI Assistant | 48 | 0.9% | 70 | 0.2% |
| Paid Social | 46 | 0.8% | 51 | 0.1% |
| Unassigned | 16 | 0.3% | 15,746 | 38.6% |

- **First touch vs last touch:** search and Performance Max bring 20% of new users but only 6% of sessions. Returning visits come back as Direct or Unassigned (mostly app sessions).
- Paid Social (TikTok, X) barely appears in GA4 web (tqa-002). Those campaigns drive app installs, which Singular sees.

## 4. Google Ads: platform claims (BigQuery, `CampaignBasicStats`)
⚠ **Correction (tqa-022):** earlier readouts used `CampaignStats`, which reported 6,243 SAR for 9–14 Nov. The real account spend is higher.

| Campaign | Spend 9–15 Nov | Clicks | Claimed conversions |
|---|---|---|---|
| Minto \| Above 5Mn (Search, B2B) | 3,693.17 SAR | 808 | 30 web B2B form success |
| Minto \| App installs - Android | 2,739.21 SAR | 1,521 | 319 first open + 143 kyc_completed (GA4 import, doubled: tqa-007/016) |
| Minto \| App promotion - iOS | 2,722.30 SAR | 2,429 | 210 first open |
| **Total** | **9,154.68 SAR** (= account total) | 4,758 | 702 |

None of these are backend conversions. They don't count toward the ledger.

## 5. Singular (attribution), W46, SAR
| Network | Cost | Network-reported installs | Singular-attributed installs |
|---|---|---|---|
| Google Ads | 9,122.25 | 532 | 1,837 |
| TikTok Ads (iOS) | 7,534.41 | 166 | 194 |
| X (iOS) | 6,999.49 | not reported | not reported |

Singular's Google Ads cost is within 0.4% of BigQuery `CampaignBasicStats`.

## Trend verdicts (direction only)
- **Google Ads:** ➡ steady. Spend flat at about 1,300 SAR a day; Singular installs flat.
- **TikTok iOS:** ⬇ cost per install up four weeks running (paid-media review: INVESTIGATE).
- **X iOS:** ❓ disputed. 7,000 SAR a week and no install data from any source.
- **Organic Search and AI Assistant:** steady share of first touch. Only one full week of GA4 history, so no trend yet.

## Blind spots
- Backend coverage under 4%.
- No backend last touch (tqa-019).
- Backend campaign names (`minto_manafa_b2c` etc.) match only 2% of Google Ads campaign names.
- Backend click IDs match 0 Ads gclids.
- GA4 and Google Ads history start 6–7 Nov.
- Meta, TikTok and X platform data aren't in BigQuery.
