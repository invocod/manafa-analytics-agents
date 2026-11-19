# 🧭 Channel attribution — W46 (9–15 Nov 2026), run 19 Nov

Run: run-20261119-0853 · bi-channel-attribution · started from the local Command Center, after bi-tracking-health (its escalation tqa-012 concerns the suspended `gold` layer, not the production ledger used here).
**Verdict: no budget shift (confidence low). Every W46 input is unchanged since run-20261118-2047 (backend 324,198 events; GA4 W46 conversions, Ads 9,154.68 SAR and Singular W46 rows re-read and identical), so the full readout in `channel-attribution-2026-11-18b.md` stands.**

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

## Re-checked this run (Observed)
- **Ledger (backend, W46):** registrations 550; deposits 457 / 5,754,086.82 SAR (no USD); investments 6,396 / 22,764,000 SAR. Attributed share 3.8% / 1.3% / 1.4% (tqa-014).
- **GA4 conversions (one per `event_uuid`, W46):** registrations 437 (google/cpc first touch 105; Paid Search + Cross-network last touch 105; Direct 250 FT / 241 LT); deposits 414 (google/cpc 21 FT / 20 LT; Direct 363 / 312; Unassigned LT 57); investments 5,403 (Unassigned LT 3,410). Identical to 18 Nov.
- **GA4 sessions W46:** channel mix identical to 18 Nov (confirmed in bi-tracking-health this run).
- **Google Ads (`CampaignBasicStats`, W46):** 9,154.68 SAR; claims 702 by action unchanged. 16–18 Nov now in the transfer (not judged, 72-hour rule).
- **Singular sheet (own section):** gate passed (header unchanged and PII-free, 707 rows, 0 duplicate grain rows, SAR only, table cost 126,401.48 = check 126,401.48, rows 707 = 707, data to 18 Nov, ETL 18 Nov 22:25 UTC). W46 rows unchanged: TikTok iOS cost 7,534.41 SAR, network installs 166, Singular-attributed installs 194. Early, not judged: TikTok iOS 16–18 Nov Singular-attributed installs 36 / 38 / 27 at ~1,080 SAR a day.

## Trend verdicts (direction only, where sources agree)
- Google Ads ➡ steady. TikTok iOS ⬇ (both Singular measures fall at flat cost). X iOS ❓ disputed (spend, no installs reported). Organic Search / AI Assistant: one full GA4 week, no trend yet.

## Not covered
- Meta, TikTok and Snapchat platform data (not in BigQuery); Singular conversion events (not in the sheet).
- W47: backend replica frozen since 17 Nov (tqa-023).
- Slack: not allowed in this run; this file is the deliverable.

_Decision support by the Manafa BI agent, for a named human to review. Aggregates only._
