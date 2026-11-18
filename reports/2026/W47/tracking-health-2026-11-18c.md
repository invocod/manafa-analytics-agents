# 🔍 Tracking health — W46 (9–15 Nov 2026), third run 18 Nov

Run: run-20261118-2047 · bi-tracking-health · started from the local Command Center
**Verdict: 🚨 ESCALATION stands (tqa-012). No new issues, none resolved. The backend replica has not moved since 17 Nov 13:47 UTC, so every check repeats the 14:50 UTC result.**
**GA4 readiness: not yet (lowest: identity_verified 27.3%).**

## Freshness
| Source | Coverage | Note |
|---|---|---|
| Backend `mi_analytics_events` | complete to 16 Nov; 17 Nov partial (to 19:46 Riyadh) | still 324,198 events. Replica idle about 31 h (tqa-023). Stale on 20 Nov without a refresh |
| GA4 raw export `google_analytics` | to 17 Nov | daily tables only |
| Google Ads transfer | to 17 Nov | |
| gold | rebuilt 18 Nov 17:16, still staging | suspended (tqa-012) |
| Singular sheet | not re-read this run | no Singular figure is judged in this loop |

Judged window: through 15 Nov (72-hour rule). 16–17 Nov are shown, not judged.

## Checks (Observed unless marked)
- **Backend heartbeat, 3–15 Nov:** no zero days on registration, KYC, deposit or investment. All days sit inside the refreshed same-weekday bands except Sun 15 Nov investments 1,631 (band 504–1,296), which is offering-shaped and expected. Fri 13 Nov (registrations 54, KYC 85) is now inside the refreshed Friday bands (51–139 and 58–218), so the watch item closes. Mon 16 Nov (not judged): registrations 83, KYC 104, deposits 71, investments 733.
- **Receipt, GA4 ÷ backend deliveries that succeeded, W46** (unchanged; tqa-007, ISQ-6053):

  | Event | Backend sent OK | GA4 | Ratio |
  |---|---|---|---|
  | auto_invest_disabled | 69 | 156 | 2.26 |
  | bank_account_removed | 17 | 36 | 2.12 |
  | passcode_enabled | 130 | 259 | 1.99 |
  | withdrawal_completed | 1,065 | 2,025 | 1.90 |
  | login_completed | 16,997 | 32,043 | 1.89 |
  | kyc_completed | 395 | 733 | 1.86 |
  | bank_account_added | 116 | 211 | 1.82 |
  | registration_completed | 437 | 739 | 1.69 |
  | identity_verified | 450 | 629 | 1.40 |
  | investment_completed / deposit_success / withdrawal_settled / auto_invest_enabled | | | 1.00 / 0.98 / 0.99 / 1.00 |

  Every extra copy has no `event_uuid` and sits on the app streams; the web stream has 0. No ratio moved more than 0.15 from baseline.
- **GA4 coverage (rule 6), W46, the only week closed in both sources:** deposit_success 90.6%, investment_completed 84.5%, registration_completed 79.5%, kyc_completed 47.5%, auto_invest_enabled 40.1%, identity_verified 27.3%. Consecutive ready weeks: 0. W47 (16–17 Nov partial) is open and not judged. Blocker: tqa-013 (ISQ-6056).
- **Delivery health, GA4 deliveries marked degraded (`no_ga_client_id`):**

  | Week of | web | iOS | Android |
  |---|---|---|---|
  | 26 Oct | 64.0% | 4.8% | 3.6% |
  | 2 Nov | 63.2% | 5.2% | 4.1% |
  | 9 Nov | 55.8% | 6.2% | 4.5% |

  Singular (`no_device`) shows the same shape. No step above 10 points and no new reason.
- **Ledger integrity:** gold (built 18 Nov 17:16) holds 161 investments for W45 and 65 for W46. Production holds 4,717 and 6,396. tqa-012 stands.
- **UTM audit, GA4 sessions W46:** 24,755 sessions (any event in the 9–15 Nov tables). Direct 72.0%, Organic Search 11.0%, Unassigned 5.5%, Cross-network 5.3%, Paid Search 3.4%; web Direct 31.1%. 262 distinct source/medium pairs. PII-shaped values: 0.
  - LinkedIn/Social 83 sessions and `paid_social` medium 48 sessions (tqa-003).
  - Internal placement names as `utm_source`: 52 sessions (tqa-004, ISQ-6060).
  - Developer and preview referrers: 231 sessions (tqa-015, ISQ-6061).
- **Channel groups:** no creator, newsletter, podcast, community or referral-program medium is live, so their mapping can't be checked. Paid social is tagged only on web LinkedIn and Twitter (48 sessions, which land in Paid Social). TikTok, Snapchat and Meta have 0 tagged sessions (tqa-002). LinkedIn/Social lands in Organic Social.
- **Google Ads conversion actions, W46:** Android First open 319, iOS First open 210, Android `kyc_completed` (GA4 import) 143, web `above-5-b2b-b2g-ar-success` 30. There is no registration action. Primary flags aren't in the transfer, so they stay Unknown (tqa-016, pm-fix-001 staged).
- **GA4 naming vs Event Standard v2.1, W46 (635,454 events):** standard 96.9%, legacy 1.07% (56 names; top app_view_page_viewed 1,801, Opportunity_Details_View 1,130, Logged_in 1,041), Remove-list 2,143 (User_launches_the_app 1,527, Transaction_View 607), not in the standard 1.69% (16 names; without the automatic `firebase_campaign` 1,600 it is 15 names / 9,128, which is tqa-011 unchanged). Completion still exceeds start: kyc_completed ÷ kyc_started 1.69, withdrawal_completed ÷ withdrawal_started 1.85 (tqa-007). Withdrawal_Click = Withdrawal_Success 99 = 99 (tqa-009).

## Fix checks on open tickets (GA4 raw export, 11–17 Nov, aggregates only)
| Issue / ticket | Fix criterion | Latest | Status |
|---|---|---|---|
| tqa-024 / ISQ-6093 | no users with the `name` user property for a full week | 2,304 users on 17 Nov (1,264–2,801 a day) | not fixed |
| tqa-005 / ISQ-6059 | no withdrawal-reference page paths | 58 page views 11–17 Nov (2 on 17 Nov) | not fixed |
| tqa-021 / ISQ-6084 | generic screen classes under 20% of app views | named share 80–83% a day | correction stands (~80% named); ticket title not yet narrowed |
| tqa-004 / ISQ-6060 | no internal placement names as source | 52 sessions W46 | not fixed |
| tqa-015 / ISQ-6061 | no dev/preview referrers | 231 sessions W46 | not fixed |
| tqa-007 / ISQ-6053, tqa-013 / ISQ-6056 | ratios ~1.0; web degraded share falls | unchanged | not fixed |

## Updated
- **tqa-023:** replica idle about 31 h; still 324,198 events. Stale point 20 Nov.
- **tqa-012:** unchanged after the 17:16 rebuild.
- **Watch item, Fri 13 Nov:** closed. The refreshed Friday bands contain both values.

## Jira
- 0 drafts awaiting approval. 12 tickets under ISQ-6052. No ticket meets its fix criterion, so no "verified fixed" comment is staged.
- The local Command Center still shows draft d-tqa-024 as "staged", because Jira isn't configured locally. The repo records ISQ-6093, created 18 Nov through the claude.ai Command Center button. Don't approve it again locally: that would create a duplicate.

## Not covered
- Google Ads Primary-conversion flags (chk-06) and GA4 key-event settings (chk-07).
- Meta, TikTok and Snapchat platform data (not in BigQuery).
- Singular sheet (not re-read this run).
- W47: not closed.
- Slack: delivery tool refused in this run; this file is the deliverable.

_Decision support by the Manafa BI agent. Aggregates only; no user-level data read or reported._
