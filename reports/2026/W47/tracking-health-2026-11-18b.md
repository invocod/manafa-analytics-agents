# 🔍 Tracking health — W46 (9–15 Nov 2026), second run 18 Nov

Run: run-20261118-1450 · bi-tracking-health · on demand from chat
**Verdict: 🚨 ESCALATION stands (tqa-012). No new issues. No new data since the 10:08 UTC run, so every check repeats this morning's result.**
**GA4 readiness: not yet (lowest: identity_verified 27.3%).**

## Freshness
| Source | Coverage | Note |
|---|---|---|
| Backend `mi_analytics_events` | complete to 16 Nov; 17 Nov partial (to 19:46 Riyadh) | 324,198 events, identical to the 10:08 UTC run. Replica idle about 25 h (tqa-023). Stale on 20 Nov without a refresh |
| Backend deliveries | 642,066 rows | unchanged |
| GA4 raw export `google_analytics` | to 17 Nov | daily tables only |
| Google Ads transfer | to 17 Nov | |
| Singular sheet | 11 Oct – 17 Nov, ETL 18 Nov 10:47 UTC | 690 rows, 0 duplicate rows, SAR only, both cost totals equal (122,972.78) |
| gold | rebuilt 18 Nov 17:16, still staging | suspended (tqa-012) |

## Checks (Observed unless marked)
- **Backend heartbeat, 3–16 Nov:** no zero days on any key event. W46 totals: registrations 550, KYC 831, identity verified 1,654, deposits 457, investments 6,396, auto-invest enabled 574 (daily rows sum to the weekly query).
  - **Watch, not an issue:** Fri 13 Nov is below its provisional same-weekday band on two events: registrations 54 (band 61–132) and KYC 85 (band 100–189). Deposits 24 and investments 68 are inside their bands.
  - Self-check: all backend events that day were 2,186 against 3,178 on Fri 6 Nov, and GA4 sessions were 2,136 against 2,871. Two independent sources fell together, and Sat 14 and Sun 15 are back in band. This reads as a quiet day, not a tracking break (Inferred). Bands hold 6 points per weekday and stay provisional. Routed to bi-daily-kpi-watch.
  - Mon 16 Nov: registrations 83 (band 82–151), inside by one.
- **Receipt, GA4 ÷ backend deliveries that succeeded, full W46** (unchanged from this morning; tqa-007, ISQ-6053):

  | Event | Ratio |
  |---|---|
  | auto_invest_disabled | 2.26 |
  | bank_account_removed | 2.12 (36 vs 17, small volume) |
  | passcode_enabled | 1.99 |
  | withdrawal_completed | 1.90 |
  | login_completed | 1.89 |
  | kyc_completed | 1.86 |
  | bank_account_added | 1.82 |
  | registration_completed | 1.69 |
  | identity_verified | 1.40 |
  | investment_completed, deposit_success, deposit_failed, withdrawal_settled, auto_invest_enabled | 0.98–1.01 |

  Every extra copy (no `event_uuid`) sits on the app streams; the web stream has none. The duplicate rule holds.
- **GA4 coverage, GA4 server-sent events ÷ backend events, W46** (the only week closed in both sources):

  | Event | Coverage |
  |---|---|
  | deposit_success | 90.6% |
  | investment_completed | 84.5% |
  | registration_completed | 79.5% |
  | kyc_completed | 47.5% |
  | auto_invest_enabled | 40.1% |
  | identity_verified | 27.3% |

  None is inside 98–102%. Consecutive ready weeks: 0. Blocker: tqa-013 (ISQ-6056).
- **Delivery health, GA4 deliveries marked degraded (`no_ga_client_id`):**

  | Week of | web | iOS | Android |
  |---|---|---|---|
  | 19 Oct | 42.9% | 4.7% | 3.0% |
  | 26 Oct | 64.0% | 4.8% | 3.6% |
  | 2 Nov | 63.2% | 5.2% | 4.1% |
  | 9 Nov (full) | 55.8% | 6.2% | 4.5% |

  No step above 10 points and no new degraded reason (`no_ga_client_id` for GA4, `no_device` for Singular). iOS keeps creeping up (4.7% to 6.2% in 4 weeks); watch.
- **Ledger integrity:** gold W46 holds 65 investments / 94,000 SAR; production holds 6,396 / 22,764,000 SAR. gold W45 is still 161 / 238,000 (the staging figure). gold was rebuilt again today and is unchanged. tqa-012 stands.
- **Channels (GA4 sessions, W46):** 24,650 sessions; Direct 72.0%, Unassigned 5.5% (baseline 72.1% / 5.4%). 262 distinct source/medium pairs.
  - Developer and preview traffic: 231 sessions (tqa-015, ISQ-6061).
  - Internal placement names as `utm_source`: 50 sessions (tqa-004, ISQ-6060, now "In Progress Dev" in Jira; no fix visible in the data yet).
  - `paid_social` medium: 48 sessions; 97 sessions carry upper-case source or medium (tqa-003).
  - PII-shaped values in source, medium or campaign: 0.
  - Custom mediums (creator, newsletter, podcast, community, referral-program): 0 sessions, so their channel mapping can't be checked.
- **Google Ads conversion actions, W46:** Android First open 319, iOS First open 210, Android `kyc_completed` (GA4 import) 143, web `above-5-b2b-b2g-ar-success` 30. No registration action. tqa-016 unchanged. Primary flags aren't in the transfer: Unknown.
- **GA4 naming vs Event Standard v2.1, W46:** standard names 96.9% of 635,454 events; legacy 1.2% (59 names, 7,385 events); not in the standard 1.7% (16 names; 1.4% without the automatic `firebase_campaign`); Remove-list 1,527 (`User_launches_the_app`). Same as baseline. Completion still exceeds start on the doubled events: kyc_completed 733 vs kyc_started 435; withdrawal_completed 2,025 vs withdrawal_started 1,093.

Session total basis: sessions counted on the first `event_date` seen in 8–16 Nov tables. The 12:49 UTC figure was 24,615 on a slightly different basis (0.1% apart).

## Singular (attribution) — Singular sheet
Gate passed (header unchanged, no user-level column, 0 duplicate rows, SAR only, two cost totals equal, latest date 17 Nov). No Singular figure is judged in this loop beyond the gate.

## Updated
- **tqa-023:** replica idle about 25 h; still 324,198 events. Stale point 20 Nov.
- **tqa-012:** gold rebuilt 18 Nov 17:16, still staging-sized.
- **tqa-007:** `bank_account_removed` shows the same doubling (small volume).
- **tqa-004:** ISQ-6060 moved to "In Progress Dev".
- **tqa-024:** Amir approved the draft with the Command Center button at 13:34 UTC; ticket **ISQ-6093** exists (To Do). Synced to the repo.

## Jira
- 0 drafts awaiting approval. 12 tickets under ISQ-6052.
- No ticket meets its fix criterion yet, so no "verified fixed" comment is staged.
- ISQ-6084 still carries its original title after the correction comment (pending check stays open).

## Not covered
- Google Ads Primary-conversion flags (chk-06).
- GA4 key-event settings (chk-07).
- Meta, TikTok and Snapchat platform data (not in BigQuery).
- W47: not closed; only 16 Nov is complete in the backend.

_Decision support by the Manafa BI agent. Aggregates only; no user-level data read or reported._
