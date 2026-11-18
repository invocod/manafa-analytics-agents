# Paid media review — W46 (9–15 Nov 2026), re-read with full Google Ads stats and GA4

Run: run-20261118-2037 · 2026-11-18 · bi-paid-media-review
Sources: BigQuery `google_ads` (customer 3343082801), BigQuery `google_analytics` (GA4 raw export), Singular sheet (`mbi_summary`). All fresh to 17 Nov. W47 is still open and 16–18 Nov are inside the 72-hour window, so W46 is still the newest week that can be judged.

**Verdict:** Google Ads → **FIX** (Android: GA4-imported `kyc_completed` is counted in the bidding conversions, tqa-016; staged plan below). TikTok iOS → **INVESTIGATE** (stands). X iOS → **INVESTIGATE** (stands).

What's new since run-20261117-1123:
1. Last run's Android blocker is resolved. The "action table is 2× the campaign total" gap came from our vetted query (tqa-022), not from double counting.
2. GA4 server-sent conversions per campaign are now shown next to the Google Ads claims (CLAUDE.md rule 5).

Decision-support only. No budget, bid, status, conversion-goal or tracking change was made.

Marks: **O** = Observed, **I** = Inferred.

## Google Ads (BigQuery) — W46 spend 9,155 SAR

Spend source:
- **O:** The vetted `gads_campaign_daily.sql` reads `CampaignStats`, which misses non-click app-campaign spend (tqa-022, high, open). It gives 7,562 SAR.
- **O:** `CampaignBasicStats` gives **9,154.68 SAR**, which equals `AccountBasicStats` (two independent tables).
- This report uses `CampaignBasicStats`, read ad hoc and aggregated. Changing the vetted query still needs Amir's OK.
- Earlier W46 figures (7,564 SAR, Android 1,258 SAR) understate spend by 17% overall and by 54% on Android.

Conversions are judged on 9–13 Nov only (72-hour rule). Claimed CPA = Mon–Fri spend ÷ Mon–Fri claimed conversions (same window).

| Campaign | Spend W46 | Clicks | CTR | Claimed conv 9–13 Nov (by action) | Claimed CPA | GA4 server-sent, last touch, 9–13 Nov (floor) | Call |
|---|---|---|---|---|---|---|---|
| App promotion - IOS \| App installs | 2,722 | 2,429 | 6.9% | 153 (iOS First open 153) | 12.9 | reg 5 · dep 1 · inv 0 | **HOLD** |
| Above 5Mn (B2B leads, Search) | 3,693 | 808 | 11.5%* | 20 (GA4-imported B2B form success 20) | 124.0 | reg 14 · dep 3 · inv 5 | **INVESTIGATE** |
| App installs - Android | 2,739 | 1,521 | 1.3% | 323 (First open 225 + GA4-imported kyc_completed 98) | 6.1 (8.7 per first open) | reg 52 · dep 11 · inv 24 | **FIX** |

\*Above 5Mn impressions differ between the two tables (7,002 in `CampaignBasicStats` vs 11,916 in `CampaignStats`). The CTR uses `CampaignBasicStats`. The earlier 6.78% used `CampaignStats`.

The GA4 column has its own counting:
- Labelled GA4.
- One per `event_uuid`, by GA4 session last-click campaign.
- It is a floor: GA4 receives 47–91% of backend events (tqa-013).
- Never divided into spend, never added to the Ads column.
- Backend attribution by campaign stays blocked (tqa-014).

**Creative:** History starts 7 Nov, so the ranges are provisional.
- **O:** iOS CTR was 8.6% (7–8 Nov), 6.9% (W46) and 8.2% (16–17 Nov, unsettled).
- **O:** Android CTR was 1.3%, 1.3% and 1.1%.
- No fatigue pattern yet.

**Landing:** Unchanged since run-20261117-0603.
- **O:** Above 5Mn ads land on `manafa.sa/lpg`. One ad carries `utm_campaign=Minto_Manafa_B2B`, which breaks the UTM convention (uppercase, underscores). The broad-KW ad group carries no UTMs.
- App campaigns have no final URLs.

### iOS installs — HOLD
- **O:** Spend was 368–407 SAR/day. Claimed conversions are all First open.
- **I:** Nothing named to fix.

### Above 5Mn (B2B borrower leads) — INVESTIGATE (stands)
- **O:** Daily spend swung from 258 to 778 SAR in W46. W47 so far: 598–612 SAR/day.
- **O (new):** GA4 makes this borrower-lead campaign the last touch for 17 investor registrations, 5 deposits and 12 investments across the full W46.
  - **I:** Either borrower-intent searches also bring in investors, or session attribution is crediting returning investors who click a brand-like ad. Not settled.
- **Settling check (unchanged):** the CRM B2B lead count for 9–13 Nov, compared with the 20 claimed.

### Android installs — INVESTIGATE → FIX (tqa-016)
- **O:** For 9–13 Nov, the sum of claimed conversions per action (225 + 98 = 323) equals the campaign's conversions in `CampaignBasicStats` (323). The same holds for iOS (153 = 153) and Above 5Mn (20 = 20).
  - So the "2×" from last run was the `CampaignStats` undercount (161), not double counting.
- **I (strong):** `metrics_conversions` only includes actions set to count in Conversions. So GA4-imported `kyc_completed` is counted for bidding. It is 30% of the campaign's claimed conversions.
  - GA4 duplicates app events (tqa-007).
  - The campaign has no registration action (tqa-016).
- **Staged plan (for the paid-media owner to approve; the agent changes nothing):**
  1. In Google Ads → Goals → Conversions → Summary, confirm `kyc_completed` (Android) is Primary for this campaign's goal.
  2. If it is, decide the bidding event: keep First open only, or replace `kyc_completed` with a de-duplicated server-sent event (e.g. `registration_completed` once per `event_uuid`).
  3. Set the duplicated import to Secondary, and note the change date for the learning-phase read.
  4. Measure: after 14 days, check Android claimed conversions per action and GA4 server-sent registrations per 1,000 SAR against W46 (52 reg on 1,959 SAR Mon–Fri).
- **Self-check:**
  - This is not a platform-vs-backend disagreement; it is a conversion-goal setting. So FIX, not INVESTIGATE.
  - Conversion lag doesn't apply: the action/total equality holds every day.

## Singular (attribution) — source: Singular sheet, `mbi_summary`

Gate passed:
- Header unchanged, no PII column.
- 690 rows, 11 Oct → 17 Nov.
- 0 duplicate grain rows, SAR only.
- `table_cost_total` = `cost_total_check` = 122,972.78 SAR; rows 690 = 690.
- Last ETL 18 Nov 17:05 UTC.

### TikTok iOS — INVESTIGATE (stands)

| Period | Spend SAR | Clicks | Network installs | Singular installs | Click→install (Singular) | Cost per install (Singular) |
|---|---|---|---|---|---|---|
| W46 Mon–Fri (settled) | 5,392 | 2,916 | 128 | 129 | 4.4% | 41.8 |
| W46 full week | 7,534 | 4,005 | 166 | 194 | 4.8% | 38.8 |
| W47 16–17 Nov (inside 72h, not judged) | 2,163 | 1,018 | 52 | 73 | 7.2% | 29.6 |

- **O:** W46 settled installs were restated 127 → 129, so cost per install moved from 42.5 to 41.8. The 4-week rise (23.5 → 41.8) stands.
- **O:** The first W47 days read 7.2% click→install. That is above the 6% "postback lag" line set last run, but these days are unsettled and can't be judged.
- The settling read stays the same: W47 Mon–Fri once settled (from 23 Nov).
- Owner: TikTok account owner.

### X (Twitter) iOS — INVESTIGATE (stands)
- **O:** W46: 7,000 SAR, 4,011 clicks. 16–17 Nov: 1,998 SAR, 1,182 clicks.
- **O:** Installs are still not reported for any day. Last run counted 33,550 SAR from 12 Oct to 15 Nov; spend has continued at ~1,000 SAR/day since, with no measurable outcome.
- **Settling check (unchanged):** is an X install postback / SKAN mapping configured in Singular for the iOS app? Owners: the X account owner and the Singular admin.

## Staged for approval
1. **Android conversion goal (tqa-016):** the plan above. Owner: paid-media owner.
2. **Vetted spend query (tqa-022):** switch `sql/readonly/gads_campaign_daily.sql` totals to `CampaignBasicStats`, then re-issue W46 spend in the digest. Needs Amir's OK. Not changed by this run.

## Facts vs hypotheses
- **Facts:**
  - All spend, click, conversion and install figures, computed in BigQuery from row-level data.
  - The action-sum equality and the `CampaignBasicStats` = `AccountBasicStats` match. The second, independent read of W46 spend is 9,154.68 SAR in both.
- **Hypotheses:**
  - `kyc_completed` is Primary. Inferred from the data; the UI check confirms it.
  - Why investors arrive via the B2B campaign.
  - The three TikTok post-click causes.
  - X run for reach only.

## Missing data
- The Primary flag in the Google Ads UI.
- The CRM B2B lead ledger.
- TikTok creative × placement data.
- X install attribution.
- Backend conversions by campaign (tqa-014).
- Meta and Snapchat platform data: not configured (not in BigQuery).
- Slack delivery: not allowed in this session.
