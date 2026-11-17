# 🧭 Attribution — week 46 (9–15 Nov 2026)

Run `run-20261117-0733` · bi-channel-attribution · decision support, not a decision.

**Windows (each source its own):** backend ledger Mon–Wed 9–11 Nov (replica ends 12 Nov, partial) · GA4 and Google Ads Mon–Sat 9–14 Nov (15 Nov is inside the 72-hour window) · Singular sheet Mon–Sat 9–14 Nov.

```
🧭 Attribution — week 46
Ledger (backend, Mon–Wed): reg 256 | dep 235 (SAR 3.85M) | inv 4,113 (SAR 15.2M)   (attributed coverage: reg 5.1% / dep 0.4% / inv 1.3%)
Backend-attributed by source: reg google/cpc 11, chatgpt.com 2 · dep google/cpc 1 · inv google/cpc 44, x/paid_social 11   (attributed share only)
GA4 (9–14 Nov): new users by first-touch — Direct 50%, Organic Search 19%, Cross-network 11%, Paid Search 9%; sessions — Direct+Unassigned 85%
Google Ads (9–14 Nov): spend 6,243 SAR; claims First open iOS 183 / Android 273, Android kyc_completed 120 (tqa-016), B2B form 25
Singular (9–14 Nov): 20,038 SAR; attributed installs Google Ads 1,579, TikTok 159, X not reported
Disputed: X (Twitter) — spend steady, no install data, backend-attributed investments 4 → 11 | Blind spots: direct+unassigned = 85% of sessions
Recommendation: no budget shift this week (confidence: low) — fix measurement first (tqa-018, tqa-019, tqa-014)
Not covered: Meta, TikTok, Snapchat platform data; Singular conversion events
```

## 1. Ledger (backend, production) — Observed
Mon–Wed of each ISO week, so W46 compares like with like.

| Event | W46 | 4-wk median (W42–W45) | 4-wk range | vs median |
|---|---|---|---|---|
| registration_completed | 256 | 316.5 | 200–362 | −19% |
| deposit_success | 235 | 327.5 | 251–477 | −28% (below range) |
| deposits SAR | 3.85M | 8.11M | 4.68M–13.39M | −52% (below range); no USD deposits |
| investment_completed | 4,113 | 2,316.5 | 1,264–3,204 | +78% (above range) |
| investments SAR | 15.2M | 9.28M | 7.31M–11.11M | +64% |

Deposits are below their 4-week range for the second week running (the exec digest flagged W46 Mon–Wed too). That belongs to bi-daily-kpi-watch / the digest; it's noted here because no channel explains it (99.6% of deposits are unattributed).

## 2. Backend attribution — Observed
Coverage (share carrying `attribution.acquisition_source`): **reg 5.1% · dep 0.4% · inv 1.3%** — inside the W41–W45 band for registrations (4.1–5.9%), below it for deposits (1.0–1.8%) and inside for investments. The unattributed 95%+ is **not extrapolated** (tqa-014).

| Source (acquisition = last) | reg | dep | inv |
|---|---|---|---|
| google / cpc | 11 | 1 | 44 (web 24, iOS 20) |
| x / paid_social | — | — | 11 (iOS) |
| chatgpt.com | 2 | — | — |

**New finding (tqa-019):** `attribution.last_*` equals `attribution.acquisition_*` on 1,026 of 1,038 attributed events since 7 Sep (98.8%). The backend carries no separate last-touch, so first-touch vs last-touch can only be read from GA4.

## 3. GA4 (own numbers only) — Observed
9–14 Nov. The transfer has no complete earlier week, so there is no GA4 trend yet.

| Channel | New users (first-touch) | share | Sessions (session channel) | share excl. Unassigned | engaged |
|---|---|---|---|---|---|
| Direct | 2,309 | 50.1% | 15,305 | 75.6% | 74% |
| Organic Search | 870 | 18.9% | 2,332 | 11.5% | 92% |
| Cross-network | 507 | 11.0% | 1,261 | 6.2% | 77% |
| Paid Search | 403 | 8.7% | 718 | 3.5% | 91% |
| Referral | 223 | 4.8% | 304 | 1.5% | 88% |
| Organic Social | 214 | 4.6% | 234 | 1.2% | 96% |
| AI Assistant | 40 | 0.9% | 58 | 0.3% | 98% |
| Paid Social | 37 | 0.8% | 41 | 0.2% | 61% |
| Unassigned | 10 | 0.2% | 12,672 | — | 0.4% |
| **Total** | **4,613** | | **32,927** | 20,255 excl. Unassigned | |

GA4 conversion counts are not used (tqa-007 doubles registration/KYC).

## 4. Google Ads (own numbers only) — Observed
9–14 Nov, customer 3343082801 (BigQuery transfer).

| Campaign | Spend (SAR) | Clicks | Claimed conversions by action |
|---|---|---|---|
| Minto \| Above 5Mn (web, B2B) | 2,915.00 | 634 | GA4 web form success 25 |
| Minto \| App promotion – iOS | 2,242.14 | 2,085 | iOS First open 183 |
| Minto \| App installs – Android | 1,086.09 | 1,277 | Android First open 273; Android kyc_completed 120 (GA4 import, doubled — tqa-016) |
| **Total** | **6,243.23** | **3,996** | |

Google claims no registrations, deposits or investments (no such action exists), so there's no "platform claims N vs ledger" pair this week. The backend credits google/cpc with 11 registrations and 44 investments on its 1–5% attributed slice (Mon–Wed).

## 5. Singular (own section, Google Sheet) — Observed
Checks passed (671 rows, no repeats, SAR only, totals agree; data to 16 Nov). 9–14 Nov vs 2–7 Nov:

| Network · OS | Spend (SAR) | Clicks | Network installs | Singular-attributed installs | CPI (SAR, Singular) |
|---|---|---|---|---|---|
| Google Ads · Android | 2,341 (2,346) | 1,297 | 268 | 1,194 (1,172) | 2.0 |
| Google Ads · iOS | 2,328 (2,369) | 2,081 | 187 | 369 (356) | 6.3 |
| Google Ads · Web | 2,915 (3,197) | 634 | 3 | 16 (3) | — |
| TikTok · iOS | 6,454 (6,454) | 3,491 (2,574) | 149 (180) | 159 (188), −15% | 40.6 |
| X · iOS | 6,000 (5,999) | 3,396 (3,654) | not reported | not reported | — |
| **Total** | **20,038** | 10,899 | 607 | 1,738 | |

Inside Singular, Google Ads Android shows 4.5× more Singular-attributed installs than the network reports (iOS 2.0×, TikTok 1.1×). Together with its cost reading 2.2× BigQuery, this row isn't reliable yet → tqa-018.

## 6. First-touch vs last-touch (GA4 only) — Observed / Inferred
- Observed: excluding Unassigned, Organic Search brings 19% of new users but 12% of sessions; Cross-network 11% vs 6%; Paid Search 9% vs 4%. Direct is 50% of new users but 76% of sessions.
- Inferred: search (organic and paid) and Performance Max start journeys that come back as Direct, mostly in the app. That's the demand-creation vs closing gap the skill looks for; it can't yet be tied to deposits or investments because the backend has no last-touch (tqa-019) and only ~1% money-event coverage (tqa-014).

## 7. Blind spots — Observed
- GA4: Direct + Unassigned = **85.0% of sessions** (Unassigned 38.5% with 0.4% engaged = app sessions, tqa-001) and 50.3% of first-touch new users. No earlier full week to trend.
- Backend: 94.9% of registrations, 99.6% of deposits, 98.7% of investments unattributed.

## 8. Trend verdicts (only where sources agree)
| Channel | Verdict | Why |
|---|---|---|
| Google Ads | ➡ | Singular installs +2–4%, spend flat (BigQuery and Singular), backend-attributed registrations 12 → 11 |
| TikTok | ⬇ installs (Singular only) | network installs −17% and Singular installs −15% at flat spend; no backend or GA4 signal to confirm or dispute |
| X (Twitter) | disputed | spend steady, clicks −7%, no install data; backend-attributed investments 4 → 11 (tiny base) |
| GA4 channels | — | no prior full week in the transfer |

## Recommendation (for human decision, confidence low)
No budget shift. Fix three measurement gaps first, in this order:
1. **tqa-018:** Singular's Google Ads Android row (cost 2.2× BigQuery, installs 4.5× network). Until fixed, Singular CPI for Google Android (2 SAR) isn't usable.
2. **tqa-019:** populate a real last-touch in backend attribution (or drop the field).
3. **tqa-014:** attribution coverage on deposits and investments (~1%).

Worth a look now: X takes about 6,000 SAR a week with no install data in Singular. Ask the X account owner whether the Singular install postback can be enabled.

## Missing data
Backend days 12–15 Nov (replica lag) · GA4/Google Ads history before ~6 Nov (backfill requested, B2) · Meta, TikTok and Snapchat platform data (not in BigQuery) · Singular conversion events (not in the sheet).
