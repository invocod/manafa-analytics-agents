# 📊 Paid media — W46 (9–15 Nov 2026), run 19 Nov  (Google Ads spend: 9,154.68 SAR)

Run: run-20261119-0853 · bi-paid-media-review · started from the local Command Center
**Verdict:** Google Ads → **FIX** (stands; tqa-016, pm-fix-001 staged, not re-proposed). TikTok iOS → **INVESTIGATE** (stands). X iOS → **INVESTIGATE** (stands). New this run: W46 claims read for the full week (Ads now to 18 Nov, so 9–15 Nov is outside the 72-hour window); landing URLs re-read from the Ad table. History: the Ads transfer starts 7 Nov, so ranges are **provisional** (one full week).

| Account | Call | Why |
|---|---|---|
| Google Ads (3 live campaigns) | **FIX** | GA4-imported Android `kyc_completed` (143 in W46) sits inside Conversions and GA4 doubles that event (tqa-016/007). Campaign-level: iOS HOLD, Above 5Mn INVESTIGATE, Android FIX |
| TikTok iOS (Singular sheet) | **INVESTIGATE** | Singular CPI rose 3 weeks running at flat spend (settled Mon–Fri 26.6 → 35.2 → 41.8 SAR). Settling check: W47 settled click→install |
| X iOS (Singular sheet) | **INVESTIGATE** | ~7,000 SAR a week, installs not reported. Settling check: X install postback / SKAN mapping in Singular |
| Meta, Snapchat | not configured | not in BigQuery |

## Google Ads (BigQuery `CampaignBasicStats`), fixed-order check
| Campaign | Spend W46 | Clicks | CTR | CPC | Claimed conv W46 (by action) | Claimed CPA | GA4 server-sent, W46 (floor): last touch / first touch | Call |
|---|---|---|---|---|---|---|---|---|
| App promotion - IOS \| App installs | 2,722.30 | 2,429 | 6.9% | 1.12 | 210 (iOS First open 210) | 12.96 | reg 7 / 6 · dep 1 / 1 · inv 0 / 0 | HOLD |
| Above 5Mn (B2B, Search) | 3,693.17 | 808 | 11.5% | 4.57 | 30 (web B2B form success) | 123.1 | reg 17 / 19 · dep 5 / 4 · inv 12 / 21 | INVESTIGATE |
| App installs - Android | 2,739.21 | 1,521 | 1.3% | 1.80 | 462 (First open 319 + GA4-imported kyc_completed 143) | 5.93 (8.59 per first open) | reg 79 / 78 · dep 14 / 16 · inv 27 / 33 | FIX |
| **Total** | **9,154.68** | 4,758 | | | 702 claimed | | | |

GA4 columns: one per `event_uuid`, last touch = session campaign (Paid Search / Cross-network), first touch = first-user campaign with google/cpc. A floor (tqa-013), never divided into spend and never added to claims.

1. **Spend & pacing (Observed):** W46 ≈ 1,308 SAR/day. 16–18 Nov (not judged): Above 5Mn 596/day (W46 528), Android 396 (391), iOS 388 (389). No pacing break.
2. **Traffic:** CPC 1.12 / 4.57 / 1.80 SAR; CTR steady vs the 2-day W45 read except iOS (8.4% → 6.9%, W45 only 2 days). 16–18 Nov Android CTR 1.05% (not judged).
3. **Conversions:** full-week claims 702 (W46 Mon–Fri read was 496). Android claims 2.2× iOS claims on equal spend, of which 31% is the doubled KYC import. GA4 floor shows Android ads close real sign-ups (79 last touch) while iOS app installs close few (7) — Inferred: iOS first opens rarely turn into tracked registrations within the week; missing data: Singular conversion events per network.
4. **Creative fatigue:** no CTR-vs-peak drop judgeable (one full week).
5. **Landing (Ad table, latest snapshot):** Above 5Mn → `manafa.sa/lpg` with `utm_source=google&utm_medium=cpc&utm_campaign=Minto_Manafa_B2B` (case/underscore off convention, tqa-003). App campaigns carry no final URL (expected for app campaigns). No broken or localhost URL among the live campaigns.
6. **Tracking:** tqa-016 (FIX), tqa-022 (vetted query undercounts app spend; pm-fix-002 staged for Amir), tqa-018 (Singular Android cost 2.2× BigQuery).

## Singular (attribution) — Singular sheet, own numbers only
Gate passed (707 rows, 0 duplicates, SAR, totals 126,401.48 = 126,401.48, to 18 Nov). TikTok iOS W46 cost 7,534.41 SAR, network installs 166, Singular-attributed 194 (unchanged). 16–18 Nov (not judged): 36 / 38 / 27 attributed installs at ~1,080 SAR/day. X iOS W46 ~7,000 SAR, installs not reported.

## Staged for approval (unchanged, not re-proposed)
- **pm-fix-001** (paid-media owner): confirm Primary flag of Android `kyc_completed`, pick the bidding event, set the duplicated import to Secondary, measure after 14 days.
- **pm-fix-002** (Amir): switch `gads_campaign_daily.sql` totals to CampaignBasicStats (tqa-022).

## Missing data
Google Ads Conversions > Summary Primary flags (chk-06); CRM B2B lead count for Above 5Mn (claimed 30 in W46); Singular conversion events by network; Meta/TikTok/Snapchat/X platform data in BigQuery. Slack: not allowed in this run.

_Decision support only. The agent never changes budgets, bids, campaign status, tracking or ads; every plan above waits for a named human._
