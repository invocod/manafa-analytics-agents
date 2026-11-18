# 🧭 Channel attribution — W46 (9–15 Nov 2026), second run 18 Nov

Run: run-20261118-2047 · bi-channel-attribution · started from the local Command Center, after bi-tracking-health (escalation tqa-012 concerns the suspended `gold` layer, not the production ledger used here).
**Verdict: no budget shift (confidence low). Inputs are unchanged since the 10:13 UTC run (backend still 324,198 events), so all figures repeat. New this run: the GA4 conversions-by-channel readout (first vs last touch).** Each source reports in its own section; sources are never added or blended.

```
🧭 Attribution — week 46
Ledger (backend): reg 550 | dep 457 (5.75M SAR) | inv 6,396 (22.76M SAR)   (attributed coverage: reg 3.8% / dep 1.3% / inv 1.4%)
Backend-attributed by source: google/cpc reg 16, dep 5, inv 74 · x/paid_social dep 1, inv 13 · chatgpt.com reg 5   (attributed share only)
GA4 conversions by channel (floor, coverage reg 79.5% / dep 90.6% / inv 84.5%): reg — paid Google 105 first touch = 105 last touch; Direct 250 FT / 241 LT
GA4 sessions: 24,755; Direct 72.0%, Organic Search 11.0%, Unassigned 5.5%, Cross-network 5.3%, Paid Search 3.4%
Google Ads: spend 9,154.68 SAR, claims 702 (first open 529, kyc_completed 143, B2B form 30)
Disputed: X iOS | Blind spots: direct+unassigned = 77.5% of GA4 sessions (W45 78.2%)
Recommendation: no budget shift; ask performance marketing why TikTok iOS installs fell 16% at flat cost (confidence low) — for human decision
Not covered: Meta, TikTok, Snapchat platform data; Singular conversion events
```

## 1. Backend ledger: conversion truth (W46, Riyadh)
| | W42 | W43 | W44 | W45 | **W46** |
|---|---|---|---|---|---|
| Registrations | 633 | 795 | 728 | 634 | **550** |
| Deposits (count) | 585 | 547 | 888 | 646 | **457** |
| Deposits SAR | 19.08M | 18.21M | 12.13M | 10.87M | **5.75M** |
| Deposits USD | 154,437 (6) | 14,991 (3) | 154,821 (6) | 7,975 (2) | **0** |
| Investments (count) | 4,025 | 8,414 | 3,613 | 4,717 | **6,396** |
| Investments SAR | 19.17M | 29.10M | 13.72M | 17.45M | **22.76M** |

Observed: W46 totals equal the sum of the daily heartbeat rows (550 / 457 / 6,396). Deposits are down for the third week running; investments are up. The "wallet balances spent on offerings" reading from the morning run stays Inferred (Finance to confirm).

## 2. Backend attribution (tqa-014)
Share of events carrying `acquisition_source`: registration 3.8%, deposit 1.3%, investment 1.4%. The attributed rows are listed in the block above. That's too few to rank channels, and the rest isn't extrapolated. The backend has no separate last touch (tqa-019).

## 3. GA4 (product analytics), W46
**Sessions by session channel (last touch):** 24,755 sessions (any event in the 9–15 Nov tables; 24,615 on the session-start-date basis used for the blind-spot share), 20,272 engaged.

| Channel | Sessions | Engaged |
|---|---|---|
| Direct | 17,821 | 15,200 |
| Organic Search | 2,719 | 2,549 |
| Unassigned | 1,363 | 132 |
| Cross-network (PMax / app) | 1,318 | 990 |
| Paid Search | 837 | 774 |
| Referral | 335 | 292 |
| Organic Social | 251 | 241 |
| AI Assistant | 62 | 60 |
| Paid Social | 48 | 33 |

**New users by first-user source (first touch):** 8,174 new users. Direct / not set 5,003 (61.2%), Organic Search 1,401 (17.1%), Google cpc 1,148 (14.0%), Referral 419 (5.1%), other tagged 203 (2.5%).

### 3b. GA4 conversions by channel: GA4 (server-sent, a floor)
One per `event_uuid`. Coverage of backend this week: registrations 79.5%, deposits 90.6%, investments 84.5% (bi-tracking-health). Not scaled up to the backend, and not added to backend or Google Ads numbers.

| Event (GA4 total) | First touch (first-user source / medium) | Last touch (session channel) |
|---|---|---|
| Registrations (437) | direct 250 · google/cpc **105** · google/organic 59 · google-play/organic 10 · chatgpt.com 4 · bing/organic 3 | Direct 241 · Cross-network 86 + Paid Search 19 = **105** · Organic Search 73 · Unassigned 10 · Referral 4 · AI Assistant 4 |
| Deposits (414) | direct 363 · google-play/organic 28 · google/cpc 21 | Direct 312 · Unassigned 57 · Organic Search 25 · Cross-network 15 · Paid Search 5 |
| Investments (5,403) | direct 4,891 · google-play/organic 388 · google/cpc 71 · google/organic 50 | Unassigned 3,410 · Direct 1,709 · Organic Search 244 · Cross-network 27 · Paid Search 12 |

- **First vs last touch (Observed):** paid Google brings 24% of GA4 registrations on both bases (105 and 105). It also holds its share into deposits (21 first touch, 20 last touch). In this data, paid Google both creates demand and closes it; nothing is handed off to other channels.
- **Investments:** 63% have no session channel (Unassigned). Inferred: server-executed investments (auto-invest) happen outside any user session, so last touch doesn't apply to them.
- Only one full GA4 week exists (data starts 4 Nov), so there's no week-over-week trend here yet.

## 4. Google Ads: platform claims (BigQuery `CampaignBasicStats`)
| Campaign | Spend 9–15 Nov | Clicks | Claimed conversions |
|---|---|---|---|
| Minto \| Above 5Mn (Search, B2B) | 3,693.17 SAR | 808 | 30 (web B2B form) |
| Minto \| App installs - Android | 2,739.21 SAR | 1,521 | 462 (319 first open + 143 kyc_completed, GA4 import, doubled: tqa-007/016) |
| Minto \| App promotion - iOS | 2,722.30 SAR | 2,429 | 210 (first open) |
| **Total** | **9,154.68 SAR** | 4,758 | 702 |

Platform claims, not backend conversions.

## 5. Singular (attribution): Singular sheet, W46, SAR
Gate passed: header unchanged, 690 rows, 0 duplicates, SAR only, cost totals equal (122,972.78), data to 17 Nov, ETL 18 Nov 17:05 UTC.

| Network | Cost | Network-reported installs | Singular-attributed installs |
|---|---|---|---|
| AdWords (Android / iOS / Web) | 9,122.25 | 532 | 1,837 |
| TikTok Ads (iOS) | 7,534.41 | 166 | 194 |
| X / Twitter (iOS) | 6,999.49 | not reported | not reported |

## Trend verdicts (direction only, where sources agree)
- **Google Ads ➡ steady.** Spend is flat at about 1,300 SAR a day. Singular-attributed app installs are 1,762 in W45 and 1,818 in W46.
- **TikTok iOS ⬇.** Cost is flat (7,536 to 7,534 SAR). Singular-attributed installs fell 231 → 194, and network-reported installs fell 208 → 166. Both sources fall together. Paid-media review: INVESTIGATE.
- **X iOS ❓ disputed.** About 7,000 SAR a week, and no source reports installs.
- **Organic Search / AI Assistant:** one full GA4 week, so no trend yet.

## Blind spots
- GA4 Direct + Unassigned sessions: 77.5% in W46, 78.2% in W45 (4–8 Nov). Steady.
- Backend attribution coverage is under 4% (tqa-014), and the backend has no last touch (tqa-019).
- GA4 conversion counts are a floor (tqa-013).
- Backend replica idle since 17 Nov 13:47 UTC (tqa-023); W47 can't be read until it moves.

## Not covered
- Meta, TikTok and Snapchat platform data (not in BigQuery).
- Singular conversion events (not in the sheet).
- Slack delivery: tool refused this run; this file is the deliverable.

_Decision support by the Manafa BI agent, for a named human to review. Aggregates only._
