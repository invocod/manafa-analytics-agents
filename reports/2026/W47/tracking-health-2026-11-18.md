# 🔍 Tracking health — W46 (9–15 Nov 2026), run 18 Nov

Run: run-20261118-1008 · bi-tracking-health
**Verdict: 🚨 ESCALATION stands (tqa-012). 2 new high issues: tqa-022 (our Google Ads spend query) and tqa-023 (backend replica not streaming).**

## Freshness
| Source | Coverage | Note |
|---|---|---|
| Backend `mi_analytics_events` | complete to 16 Nov; 17 Nov partial (to 19:46 Riyadh) | 324,198 events (+23,810 since 17 Nov). Replica refreshed 17 Nov 13:47 UTC, then no change for 20 h |
| Backend deliveries | 642,066 rows | same refresh |
| GA4 transfer | 6–17 Nov | |
| Google Ads transfer | 7–17 Nov | |
| Singular sheet | 11 Oct – 17 Nov, ETL 17 Nov 22:24 UTC | 690 rows, 0 duplicate rows, SAR only |
| gold | rebuilt 18 Nov, still staging | suspended (tqa-012) |

## Checks (Observed unless marked)
- **Backend heartbeat:** every key event fired every day 2–16 Nov. The low days 13–14 Nov (2,186 / 2,490 events) are Fri–Sat, the same as 6–7 Nov (3,178 / 2,880). No zero days.
- **Receipt, GA4 ÷ backend `succeeded`, full W46:**

  | Event | Ratio |
  |---|---|
  | auto_invest_disabled | 2.26 |
  | passcode_enabled | 1.99 |
  | withdrawal_completed | 1.90 |
  | login_completed | 1.89 |
  | kyc_completed | 1.86 |
  | bank_account_added | 1.82 |
  | registration_completed | 1.69 |
  | identity_verified | 1.40 |
  | investment_completed, deposit_success, deposit_failed, withdrawal_settled, auto_invest_enabled | 0.98–1.01 |

  Same pattern as before. tqa-007 is unchanged (ISQ-6053).
- **Delivery health, web `no_ga_client_id` share:** auto_invest_enabled 94%, identity_verified 89%, kyc_completed 88%, deposit_failed 92%, deposit_success 45%, registration_completed 42%, login_completed 4%. tqa-013 is unchanged (ISQ-6056).
- **Ledger integrity:** gold W46 has 65 investments / 94,000 SAR; production has 6,396 / 22,764,000 SAR. tqa-012 stands. The escalation is still open with data engineering.
- **Channels (GA4 sessions, W46):** Unassigned 38.6%, Direct 46.5% (baseline 38.7% / 46.5%), 264 distinct source/mediums, 40,753 sessions.
  - Dev/preview traffic: 242 sessions (tqa-015, ISQ-6061).
  - Internal-link UTMs: 67 sessions (tqa-004, ISQ-6060).

## New issues
- **tqa-022 (high) — our own Google Ads spend query undercounts by ~17%.**
  - `sql/readonly/gads_campaign_daily.sql` reads `p_ads_CampaignStats`. That table is split by click type and leaves out non-click spend on app campaigns.
  - W46 spend: CampaignStats 7,562.34 SAR; CampaignBasicStats 9,154.68 SAR; AccountBasicStats (account total) 9,154.68 SAR.
  - Android app installs show the biggest gap: 1,258 vs 2,741 SAR.
  - This week's paid-media, digest, KPI-watch and attribution figures used the low number.
  - Owner: BI agent. Changing the query needs Amir's OK. Until then, this run reports CampaignBasicStats.
- **tqa-023 (high) — the backend replica isn't streaming.**
  - The Datastream tables were created on 12 Nov and stopped about an hour later. They jumped forward on 17 Nov 13:47 UTC and have been idle since.
  - Every backend loop is blind between refreshes. Next stale point: 20 Nov.
  - Owner: data engineering.

## Updated
- **tqa-018:** the cost gap is explained by tqa-022. Singular's Google Ads cost matches CampaignBasicStats within 0.4% on every OS. Still open: Singular-attributed Android installs are 4.5× what the network reports.

## Jira
- No new drafts this run.
- Amir created ISQ-6083 (tqa-020) and ISQ-6084 (tqa-021) with the Command Center buttons on 18 Nov. Both are synced to `state/bi-tracking-health.json`.

## Not covered
- Google Ads Primary-conversion flags (chk-06).
- GA4 key-event settings (chk-07).
- Meta, TikTok and Snapchat spend in BigQuery.
