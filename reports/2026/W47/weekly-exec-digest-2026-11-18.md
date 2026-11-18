# 📅 Manafa weekly digest — week 46 (9–15 Nov 2026), full week

Run: run-20261118-2047 · bi-weekly-exec-digest · last in the run, after bi-tracking-health and bi-channel-attribution. Replaces the Mon–Wed digest of 17 Nov (weekly-exec-digest-2026-11-17b.md).

**Measurement: 🚨 tqa-012 escalation stands.** The `gold` DWH layer reflects staging, not production. No figure below uses it. The production backend ledger is clean (no zero days, money events reach GA4 at 0.98–1.00). The backend replica has been idle since 17 Nov 13:47 UTC (tqa-023) and goes stale on 20 Nov. No figure here is marked "measurement suspect".

## Backend (truth): production `mi_analytics_events`, Riyadh weeks
| Metric | W46 | W45 | 4-wk median (W42–45) | Δ vs W45 | Δ vs median | Range W42–45 |
|---|---|---|---|---|---|---|
| Registrations | 550 | 634 | 681 | −13% | −19% | **below** (633–795) |
| Identity verified | 1,654 | 2,203 | 2,275 | −25% | −27% | **below** |
| KYC completed | 831 | 1,118 | 1,134 | −26% | −27% | **below** |
| Deposits (count) | 457 | 646 | 616 | −29% | −26% | **below** (547–888) |
| Deposits SAR | 5.75M | 10.87M | 15.17M | −47% | −62% | **below** |
| Deposits USD | 0 | 7,975 (2) | — | | | |
| Investments (count) | 6,396 | 4,717 | 4,371 | +36% | +46% | in (3,613–8,414) |
| Investments SAR | 22.76M | 17.45M | 18.31M | +30% | +24% | in |
| First investments | 60 | 171* | 65 | −65% | −8% | in |
| Auto-invested investments | 4,966 | 3,360 | 3,045 | +48% | +63% | in |
| Auto-invest enabled | 574 | 791 | 784 | −27% | −27% | **below** (610–870) |

\*W45 holds the 2 Nov one-day auto-invest batch (114 first investments).
Cross-check: registrations, deposits and investments equal the sum of the daily heartbeat rows (550 / 457 / 6,396). Amounts are per currency and never added across currencies.

## Funnel (14 days, closed cohort W44, registered 26 Oct – 1 Nov), from bi-investor-funnel
| | Web | iOS | Android |
|---|---|---|---|
| KYC | 30.0% | 89.7% | 85.3% |
| Deposit | 2.2% | **15.2%** (above band) | 4.9% |
| Invest | 1.1% | **7.7%** (above band) | 3.9% |

The iOS uplift is entirely Apple Pay first deposits (42 vs 23–27 a cohort). Web KYC is the worst leak (fx-01).

## GA4 (product analytics): GA4 raw export, W46
- 24,755 sessions, 20,272 engaged.
- Channel mix (session, last touch): Direct 72.0%, Organic Search 11.0%, Unassigned 5.5%, Cross-network 5.3%, Paid Search 3.4%, Referral 1.4%, Organic Social 1.0%, Paid Social 0.2%.
- Traffic is flat: 3,516 sessions a day in W46 vs 3,484 in W45 (4–8 Nov, the first days of GA4 data; session-start-date basis).

**Command Center (GA4) covers:** reg 79.5% · KYC 47.5% · dep 90.6% · inv 84.5% (identity_verified 27.3%, auto-invest enabled 40.1%) of the backend in W46. The page shows GA4 server-sent conversions, so its numbers run lower than this digest. GA4 is not ready to replace the backend (tqa-013).

## Google Ads (claims): BigQuery `CampaignBasicStats`, W46
- Spend 9,154.68 SAR · 4,758 clicks · 702 claimed conversions.
- Claims by type: 529 first opens, 143 GA4-imported `kyc_completed` (doubled in GA4), 30 B2B form successes.
- These are platform claims, not backend conversions.
- Spend runs about 1,308 SAR a day. The only earlier days in the transfer (7–8 Nov) ran about 1,427 SAR a day; there is no full prior week.

## Singular (attribution): Singular sheet, W46, SAR
AdWords 9,122.25 (1,837 Singular-attributed installs) · TikTok iOS 7,534.41 (194) · X iOS 6,999.49 (installs not reported).

## Movers (Observed; owners suggested)
- ⬇ **iOS registrations, 4th weekly fall:** 384 → 349 → 288 → 226 (−41%). Web fell for 3 weeks (295 → 222); Android is flat (~100).
  - GA4 traffic is flat, and Google Ads iOS installs are flat in Singular (413 → 423).
  - TikTok iOS installs fell 231 → 194 at flat cost, and X iOS reports none.
  - *Inferred:* the iOS fall sits in non-Google acquisition or in app sign-up, not in traffic volume.
  - Owner: growth / performance marketing. Loop: bi-paid-media-review (TikTok and X iOS are already INVESTIGATE).
- ⬇ **Deposits, 3rd weekly fall:** 888 → 646 → 457. Most of it is iOS (710 → 488 → 355). SAR fell 12.1M → 10.9M → 5.75M; large deposits (≥ 500k SAR) fell from 4–6 a week to 1.
  - W44 held the salary days (26–28 Oct). W46 is still below the 4-week range without them.
  - The 17 Nov watch item asked for a full W46 before routing. It is now confirmed and **routed to bi-investor-funnel and Finance**.
  - *Inferred, unverified:* investors are funding offerings from wallet balances rather than topping up.
- ⬆ **Investments +46% vs median** (6,396; 22.76M SAR). 4,966 were auto-invested. This is offering-driven and expected (Sun 15 Nov 1,631). Owner: investments / product.
- Identity verified, KYC and auto-invest enabled are all below range. They move with registrations; no separate break is visible (tracking-health heartbeat clean).

## Loop verdicts this week
- **Tracking health:** 🚨 ESCALATION (tqa-012, gold = staging).
  - 0 new issues.
  - Backend replica idle about 31 h (tqa-023).
  - No open ticket meets its fix criterion yet (e.g. the GA4 `name` user property is still set for 2,304 users on 17 Nov, ISQ-6093).
- **Channel attribution:** no budget shift (confidence low).
  - Backend attribution covers 3.8% / 1.3% / 1.4%.
  - In GA4 (a floor), paid Google brings 105 of 437 registrations on both first and last touch.
- **Paid media:**
  - Google Ads Android **FIX** (GA4-imported kyc_completed in bidding conversions; pm-fix-001 staged).
  - iOS **HOLD**.
  - Above 5Mn, TikTok iOS and X iOS: **INVESTIGATE**.
  - pm-fix-002 (switch the vetted Ads query to CampaignBasicStats, tqa-022) is waiting for Amir.
- **Investor funnel:** W44 closed; iOS above band (positive, Apple Pay); web KYC worst; fx-01 awaiting approval.
- **Campaign health:** no campaign ended. national_day_96 can't be judged (no goals or spend).
- **Daily KPI watch:** silent (no new judgeable day).

## Experiments worth considering (AI-generated, for human triage)
1. **fx-01 web KYC handoff** (staged): web KYC is 30% vs 85–90% in the apps. Success: web KYC within 14 days ≥ 50% for 2 closed cohorts. Guardrail: app KYC ≥ 85%.
2. **Apple Pay as the default first-deposit option on iOS**, earned by the Apple Pay uplift. Success: iOS 14-day deposit rate ≥ 13% for 2 closed cohorts. Guardrail: deposit_failed share doesn't rise.

## Proposed learnings (for approval)
- "The iOS first-deposit uplift since late October comes from Apple Pay; card and bank transfer stayed flat." Seen on W44 (14-day, closed) and W45 (7-day early read). It becomes final when W45 closes on 14 days (data to 22 Nov).

## Not covered / stale
- `gold` suspended (tqa-012).
- Backend replica idle (tqa-023, stale on 20 Nov), so W47 can't be read.
- Meta, TikTok and Snapchat platform data aren't in BigQuery; Singular has no conversion events.
- Google Ads Primary flags are unknown (chk-06).
- Slack delivery and git push weren't allowed in this run; this file is the deliverable.

_Decision support by the Manafa BI agent. A named human reviews before any of this drives spend, product or customer-facing decisions. Aggregates only._
