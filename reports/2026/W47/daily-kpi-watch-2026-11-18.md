# ⚠️ KPI watch — 2026-11-18 (judged through Sun 15 Nov)

Run: run-20261118-2023 · bi-daily-kpi-watch · started from the local Command Center · BigQuery `databases-472111` (me-central2), read-only.

**Verdict: one out-of-band day, already recovered. Fri 13 Nov registrations and KYC fell below their provisional same-weekday bands; every source fell together and both metrics were back in band on Sat 14 and Sun 15. Read: real demand dip, not a tracking break. No backend or GA4 conversion event read zero on any day. One money observation sits inside the unjudged 72-hour window (17 Nov, one SAR deposit of 51.8M) and is held as a watch item, not an alert.**

```
⚠️ KPI watch — Fri 2026-11-13 (backend ledger)
registration_completed: 54 vs expected 61–132 (same weekday, 6 weeks, provisional)
kyc_completed: 85 vs expected 100–189 (same weekday, 6 weeks, provisional)
Read: real (demand) — backend, GA4 sessions, GA4 server-sent events and Ads spend all fell the same day; no zero hour in backend or GA4; Sat 14 and Sun 15 back in band
Known causes ruled out: Ramadan/Eid/National Day/salary days (none in window). Possible but unconfirmed: a 13:00 session burst on Fri 6 Nov (416 sessions in one hour) that did not repeat on 13 Nov
Routed to: bi-weekly-exec-digest (demand note). Closed on detection (an-002). Same observation already filed as a watch by bi-tracking-health today.
```

## Freshness (Observed)
| Source | Latest day | Judged through | Note |
|---|---|---|---|
| Backend `manafa_financing.mi_analytics_events` | 17 Nov (partial) | 15 Nov | Replica caught up from 12 Nov; the stale flag from 17 Nov is cleared. New judged days: 12, 13, 14, 15 Nov |
| GA4 raw export `google_analytics` | 17 Nov | 15 Nov | New judged day: 15 Nov |
| Google Ads `google_ads` | 17 Nov | 15 Nov | New judged day: 15 Nov. 15 Nov restated 1,320.26 → 1,319.10 SAR |
| `gold` | — | — | Suspended (tqa-012); freshness row ignored |

## Backend ledger — judged days vs same-weekday bands (Observed; bands computed in BigQuery from 2 Oct, median ± max(3×1.4826×MAD, 30% of median), points strictly before the judged day)
| Day | Registrations | KYC | Deposits | Investments |
|---|---|---|---|---|
| Thu 12 Nov | 70 [69–127] in | 118 [99–183] in | 74 [31–165] in | 458 [0–4,656] in |
| Fri 13 Nov | **54 [61–132] LOW** | **85 [100–189] LOW** | 24 [23–104] in | 68 [0–818] in |
| Sat 14 Nov | 76 [68–125] in | 98 [48–243] in | 32 [0–129] in | 126 [0–319] in |
| Sun 15 Nov | 94 [25–185] in | 128 [98–222] in | 92 [70–131] in | **1,631 [457–1,254] HIGH** |

- Sun 15 Nov investments: GA4 server-sent investments moved the same way (1,364 vs 535 the prior Sunday); investment amount 4.94M SAR vs 3.17M the prior Sunday. Offering-shaped, the expected pattern (metrics.md). Not an alert.
- All backend events on Fri 13 Nov: 2,186 (prior Fridays 3,124–5,008), inside its own band [1,866–5,656]. Hourly backend counts never reached zero; hours 08:00–14:00 were the lowest (41–55 events/hour vs 48–116 on 6 Nov).

## GA4 (product analytics) — own numbers only (Observed)
- Judged day Sun 15 Nov: sessions 4,732 (prior Sunday 8 Nov: 4,568). Channel groups: Direct 3,461, Organic Search 518, Unassigned 240, Paid Search 183, Referral 61, Organic Social 19, Paid Social 10. One prior same-weekday point, so no band yet; no channel at zero.
- GA4 server-sent conversions (one per `event_uuid`) Sun 15 Nov: registrations 71, KYC 61, deposits 81, investments 1,364. No band yet; no zeros.
- Fri 13 Nov (context for the alert): sessions 2,136, the lowest day in the export; server-sent registrations 40 (prior Friday 55). Hourly sessions never reached zero.
- Unjudged, noted only: Paid Social sessions 1 on Mon 16 Nov (channel runs at 1–12/day); Organic Social 114 on 16 Nov and 90 on 17 Nov (typically 7–38). Re-check when judgeable.

## Google Ads (spend) — own numbers only (Reported by the platform)
- Sun 15 Nov: 1,319.10 SAR, 29,963 impressions, 727 clicks, 3 campaigns. Prior Sunday 8 Nov: 1,084.89 SAR. One prior same-weekday point, no band; no zero.
- Fri 13 Nov: 816.45 SAR, the lowest day of the transfer (weekdays run ~1,100 SAR). Paid Search sessions in GA4 that day: 59 (6 Nov: 80).

## Watch items
1. **17 Nov backend deposit amount (unjudged, inside the 72-hour window).** SAR deposit total 52.1M from 52 deposits; one deposit ≥10M SAR accounts for 51.8M. The largest single SAR deposit since 2 Oct before this was 6.47M (13 Oct); deposits ≥1M occur every few days (1.3M–6.5M). Its GA4 delivery is degraded (`no_ga_client_id`), so GA4 shows 297k SAR for the day; its Singular delivery succeeded. Read: unknown — a genuine large deposit or an amount-unit error. Re-judge on the 20 Nov run. If it stands: bi-tracking-health verifies the amount unit on the backend event; a named finance owner confirms the deposit. No customer-level data was read.
2. Mon 9 Nov registrations 74 (band 82–151) — closed: Mon 16 Nov was 83 (inside), a single low Monday with no repeat.

## Facts vs hypotheses
- Facts (Observed): the band breaks above; co-movement of all sources on 13 Nov; recovery on 14–15 Nov; the 17 Nov amount buckets and delivery statuses.
- Hypotheses (Inferred): the 13 Nov dip reflects a missing push/send or ordinary weekend softness; the 15 Nov investment spike is offering-driven; the 17 Nov amount is either genuine or a unit error. None confirmed.

## Not covered
Meta, TikTok, Snapchat platform data (not in BigQuery); Singular (attribution; not part of this loop's daily series); GA4 and Ads same-weekday bands (need 8 points, have 1–2 since 4 Nov / 7 Nov); Slack delivery (not available in this session).

Decision-support only. Any action on spend, tracking configuration or a customer deposit requires a named human owner.
