# Campaign health — 2026-11-18 (run-20261118-2032)

**Verdict: checked, nothing to do — no campaign concluded. national_day_96 stays blocked (no goals, no spend source); its backend floor was refreshed and the investment floor restated.**

Marks: **O** = Observed (computed from BigQuery / the Singular sheet), **R** = Reported (platform-claimed), **I** = Inferred.
Sources: BigQuery `databases-472111` (me-central2), read-only. Backend = `manafa_financing.mi_analytics_events`. Google Ads = `google_ads` (customer 3343082801). Singular = Google Sheet `mbi_summary` tab (validated below). Judged through **2026-11-15** (72-hour rule); 16–17 Nov used only to say whether a campaign is still spending.

## Freshness gate (O)
| Source | Latest day | Status |
|---|---|---|
| backend_events | 2026-11-17 (partial) | fresh |
| ga4 (raw export) | 2026-11-17 | fresh |
| google_ads | 2026-11-17 | fresh |
| Singular sheet | 2026-11-17 (ETL 2026-11-18 17:05 UTC) | fresh, valid |

## Did any campaign conclude? No.
**Google Ads (BigQuery, O):** three campaigns, all ENABLED, spend on every day through 17 Nov.

| Campaign | Type | Cost 9–15 Nov (SAR) | Cost 16–17 Nov (SAR) | Last spend day |
|---|---|---|---|---|
| Minto \| Above 5Mn | Search | 3,693 | 1,210 | 2026-11-17 |
| Minto \| App promotion - IOS \| App installs | App | 2,613 | 732 | 2026-11-17 |
| Minto \| App installs - Android | App | 1,257 | 405 | 2026-11-17 |

**Backend campaign tags (O):** `minto_manafa_b2b` registered users every ISO week from 15 Sep to the week of 9 Nov (15–34 per week) and is still active. `minto_manafa_b2c` carries only sporadic investment events (4 in the week of 9 Nov). `linkedin_bio` is a bio link with 4 registrations total, last in the week of 5 Oct — not a campaign. `national_day_96` is the only concluded campaign without a postmortem.

## Singular (attribution) — Singular sheet only
Validation (O): header unchanged and PII-free; 690 rows; 2026-10-11 → 2026-11-17; `duplicate_grain_rows` 0; currency SAR only; `table_cost_total` = `cost_total_check` (122,972.78); `table_rows_total` = `data_rows` (690). Gate passed.
- TikTok Ads (`Minto | App promotion | June 2026`, iOS): network cost ~1,060–1,090 SAR on every day 9–17 Nov. Still running.
- Twitter/X (`Minto | Investors | App install`, iOS): network cost ~1,000 SAR on every day 9–17 Nov; installs not reported (no postback). Still running.
- `Minto | App promotion | July 2026`: no cost on 16–17 Nov (residual rows only); not treated as a campaign (unchanged from 17 Nov).

## national_day_96 — recheck (still blocked)
Window: UTM campaign `national_day_96`, sources X / Snapchat / one Google Ads tag; attributed registrations 21–28 Sep 2026; concluded ~4 Oct; 14-day lag closed 18 Oct.

**Results (backend, attributed only — a floor, not a total; O).** First-touch (`acquisition_campaign`) and last-touch (`last_campaign`) give identical counts for this campaign: no user was re-attributed.

| Through 2026-11-15 | Registrations | Deposits (events / users) | Investments (events / users) |
|---|---|---|---|
| X | 19 | 11 / 5 | 86 / 7 |
| Snapchat | 1 | 2 / 1 | 12 / 3 |
| Google Ads tag | 1 | 0 | 0 |
| **Total** | **21** | **13 / 6** | **98 / 10** |

All deposits and investments are in SAR. Only **2 of the 98** investment events are first investments (`is_first_investment`).

**Floor restated (O, flagged):** the 16 Nov note reported 116 investment events to 11 Nov. Recomputed today with the same definition (`acquisition_campaign` OR `last_campaign` = national_day_96, `investment_completed`, Riyadh date ≤ 11 Nov) the count is **96** (98 through 15 Nov). Registrations (21) and deposits (12 to 11 Nov) reproduce exactly. I could not find the cause of the 116; it is not reproducible from the current table. Logged as an open question for tracking-QA (replica restatement vs. a different definition in the earlier run).

**Attribution coverage (O):** 1.5% of registrations in the campaign window (86 of 5,696, 20 Sep–4 Oct) carry any `acquisition_campaign`; 4.0% in the four closed weeks 19 Oct–15 Nov (109 of 2,707). The 16 Nov note's "~5%" is replaced by these measured figures (tqa-014).

**Efficiency:** not computable. No spend source covers 20 Sep–4 Oct: Google Ads in BigQuery starts 7 Nov, the Singular sheet starts 11 Oct, and X/Snapchat spend is not in BigQuery. No cost per registration or deposit is stated.

**Worked / didn't (O unless marked):**
- Worked: X carried 19 of 21 attributed registrations and 86 of 98 attributed investment events. The campaign tag was applied consistently (clean source values x / snapchat / google_ads).
- Didn't: Snapchat shows 1 attributed registration; its 12 investment events come from 3 users.
- I: with 2 first investments among 98 attributed investment events, the attributed activity is mostly repeat investing by a handful of users, not new-investor acquisition. Correlation with the campaign, not a proven cause.
- Baseline: none that is matched. The window overlaps the September launch burst (backend history is valid from 2 Oct per `context/metrics.md`), so the 5,696 registrations in-window vs 2,707 in the later four closed weeks is not a campaign effect.

**Reusable assets:** the UTM naming (`national_day_96` + per-source `utm_source`) is reusable as-is. No creative, landing-page or placement data exists in BigQuery.

**Proposed learnings (for human approval, not applied):**
1. Every seasonal push gets a brief on record with goals (registrations, deposits, budget) before launch.
2. X and Snapchat spend must reach BigQuery or the Singular sheet before the next push, or the postmortem cannot compute cost per result.
3. Campaign CPA is meaningless at 1.5–4% attribution coverage; tqa-014 is the prerequisite.
4. Track first-investment share per campaign as the quality metric alongside counts.

**Open questions (marketing):** goals; X/Snapchat spend by day; creators or placements without UTMs; whether the 16 Nov investment count (116) came from a different definition.

## Not covered
Meta, TikTok and Snapchat platform data (not in BigQuery); Singular conversion events (not in the sheet); GA4 traffic by campaign UTM for Sep–Oct (GA4 raw export starts 4 Nov); creative and landing-page performance.

## Tools not available in this run
Slack delivery and git push are refused for local Command Center runs: report written and committed locally only.
