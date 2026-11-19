# 🔍 Tracking health — W46 (9–15 Nov 2026), run 19 Nov

Run: run-20261119-0853 · bi-tracking-health · started from the local Command Center
**Verdict: 🚨 ESCALATION stands (tqa-012; not re-alerted). No new issues, none resolved. Backend replica still frozen at 324,198 events (tqa-023), so backend checks repeat; GA4 adds nothing new either (latest daily table still 17 Nov). Google Ads gained 18 Nov.**
**GA4 readiness: not yet (lowest: identity_verified 27.3%).**

## Freshness
| Source | Coverage | Note |
|---|---|---|
| Backend `mi_analytics_events` | complete to 16 Nov; 17 Nov partial (last event 17 Nov 16:46 UTC) | 324,198 events, unchanged since 17 Nov 13:47 UTC (idle ~43 h at 19 Nov 08:53 UTC, tqa-023). Stale on 20 Nov without a refresh |
| GA4 raw export `google_analytics` | to 17 Nov | no 18 Nov daily table yet |
| Google Ads transfer | to 18 Nov | CampaignStats and CampaignBasicStats |
| gold | rebuilt 19 Nov 10:15 (DWH clock), still staging | suspended (tqa-012) |
| Singular sheet | not re-read this run | no Singular figure is judged in this loop |

Judged window: through 15 Nov (72-hour rule). 16–17 Nov shown, not judged.

## Checks (Observed unless marked)
- **Backend heartbeat, 3–16 Nov:** no zero days on registration, KYC, deposit or investment. Against the stored same-weekday bands (`state/bi-daily-kpi-watch.json`, refreshed 18 Nov) every day is inside except Sun 15 Nov investments 1,631 (high; offering-shaped, expected). Point-in-time bands (priors only, computed in BigQuery this run) put registrations slightly low on Tue 3 Nov (75 vs 77–142), Mon 9 Nov (74 vs 82–152) and Fri 13 Nov (54 vs 61–132). Registrations W46 550 vs W45 634 (−13%). Read: a mild softening of sign-ups, not a tracking break (all events and GA4 sessions moved together on those days; Inferred). Routed to bi-daily-kpi-watch / bi-investor-funnel; no new issue.
- **Receipt, GA4 ÷ backend GA4 deliveries that succeeded, W46** (unchanged; tqa-007, ISQ-6053):

  | Event | Sent OK | GA4 raw | Raw ratio | GA4 per `event_uuid` ÷ sent OK |
  |---|---|---|---|---|
  | auto_invest_disabled | 69 | 156 | 2.26 | 0.99 |
  | bank_account_removed | 17 | 36 | 2.12 | 1.06 |
  | passcode_enabled | 130 | 259 | 1.99 | 1.02 |
  | withdrawal_completed | 1,065 | 2,025 | 1.90 | 1.00 |
  | login_completed | 16,997 | 32,043 | 1.89 | 1.00 |
  | kyc_completed | 395 | 733 | 1.86 | 1.00 |
  | bank_account_added | 116 | 211 | 1.82 | 1.03 |
  | registration_completed | 437 | 739 | 1.69 | 1.00 |
  | identity_verified | 450 | 629 | 1.40 | 1.00 |
  | investment_completed / deposit_success / withdrawal_settled / auto_invest_enabled | | | 1.00 / 0.98 / 0.99 / 1.00 | same |

  No ratio moved more than 0.15 from baseline; no new event near 2.0; money events inside 0.95–1.05. Mon 16 Nov alone (not judged): same pattern (deposit 1.08 on 64 sends, single-day timing).
- **Duplicate rule:** copies without `event_uuid` stay on app streams only. W46: iOS 12,874, Android 4,282, web 0. 16–17 Nov: iOS 4,449, Android 1,661, web 0.
- **GA4 coverage (rule 6), W46 (only week closed in both sources):** deposit_success 90.6%, investment_completed 84.5%, registration_completed 79.5%, kyc_completed 47.5%, auto_invest_enabled 40.1%, identity_verified 27.3%. Consecutive ready weeks: 0. W47 (16–17 Nov partial) open, not judged (partial reads: registration 87.8%, deposit 104.9%, identity_verified 35.3%). Blocker: tqa-013 (ISQ-6056).
- **Delivery health, degraded share (GA4 `no_ga_client_id`):**

  | Week of | web | iOS | Android |
  |---|---|---|---|
  | 26 Oct | 64.0% | 4.8% | 3.6% |
  | 2 Nov | 63.2% | 5.2% | 4.1% |
  | 9 Nov | 55.8% | 6.2% | 4.5% |
  | 16 Nov (1–2 days, not judged) | 47.8% | 5.5% | 3.1% |

  Singular (`no_device`) same shape. Only two reasons exist (`no_ga_client_id`, `no_device`); none new; no step above 10 points.
- **Ledger integrity:** gold (built 19 Nov 10:15) W45 161 investments / 238,000 SAR, W46 65 / 94,000 SAR; production 4,717 / 17,448,000 SAR and 6,396 / 22,764,000 SAR. tqa-012 unchanged; escalation already raised, not re-alerted.
- **UTM audit, GA4 sessions** (session on its first day; W46 9–15 Nov, plus 16–17 Nov):
  - W46: Direct 72.0%, Organic Search 11.0%, Unassigned 5.5%, Cross-network 5.3%, Paid Search 3.4%; web Direct 31.1%. 16–17 Nov: Direct 72.1%, Unassigned 4.0%; web Direct 35.1%.
  - PII-shaped values (`@`, 9+ digits) in source/medium/campaign: **0** in both windows.
  - LinkedIn/Social 83 (W46) / 25 (16–17 Nov); `paid_social` medium 48 / 4 (tqa-003). `Minto_Manafa_B2C` underscore campaign 12 / 5.
  - Internal placement names as source: 52 / 18 sessions (tqa-004, ISQ-6060).
  - Developer and preview referrers: 231 / 56 sessions (tqa-015, ISQ-6061).
  - Non-standard mediums otherwise: `ai-assistant` (chatgpt.com 60, gemini 2, GA4's own AI Assistant channel), `Data Not Available` 13.
- **Channel groups:** no creator, newsletter, podcast, community or referral-program medium is live (affiliate: 1 session, lands in Affiliates). Paid social tagged only on LinkedIn (26) and Twitter (25) and Snapchat (1), 9–17 Nov, landing in Paid Social. TikTok and Meta: 0 tagged sessions (tqa-002).
- **Google Ads conversion actions:** W46 Android First open 319, iOS First open 210, Android `kyc_completed` (GA4 import) 143, web `above-5-b2b-b2g-ar-success` 30. 16–18 Nov: 146 / 96 / 66 / 12. No registration action. Primary flags not in the transfer: Unknown (tqa-016, pm-fix-001 staged).
- **GA4 naming vs Event Standard v2.1:** W46 (635,454 events) standard 96.9%, legacy 1.07% (56 names), Remove-list 2,143 (User_launches_the_app 1,527, Transaction_View 607), not in standard 1.69% (16 names incl. automatic `firebase_campaign` 1,600; tqa-011). 16–17 Nov: standard 96.9%, legacy 0.84% (falling), Remove-list 598, not in standard 1.94%.

## Fix checks on open tickets (GA4 raw export, aggregates only)
| Issue / ticket | Fix criterion | Latest | Status |
|---|---|---|---|
| tqa-024 / ISQ-6093 | no users with `name` user property for a full week | 2,801 / 2,382 / 2,304 users on 15/16/17 Nov | not fixed |
| tqa-005 / ISQ-6059 | no withdrawal-reference page paths | 20 / 12 / 2 page views 15/16/17 Nov | not fixed |
| tqa-021 / ISQ-6084 | generic screen classes < 20% of app views | named share 83% / 83% / 81% | correction stands |
| tqa-004 / ISQ-6060 | no internal placement names as source | 18 sessions 16–17 Nov | not fixed |
| tqa-015 / ISQ-6061 | no dev/preview referrers | 56 sessions 16–17 Nov | not fixed |
| tqa-007 / ISQ-6053, tqa-013 / ISQ-6056 | raw ratios ~1.0; web degraded share falls | unchanged; web degraded drifting down (64% → 56% → 48% partial) | not fixed |

## Updated
- **tqa-023:** replica idle ~43 h; still 324,198 events. Stale point 20 Nov.
- **tqa-012:** unchanged after the 19 Nov rebuild.

## Jira
- 0 drafts awaiting approval. 12 tickets under ISQ-6052, all drafts in `jira/drafts/drafts.json` are `created`. No ticket meets its fix criterion, so no "verified fixed" comment is staged. tqa-022 (BI query) and tqa-023 (data engineering) are outside the squad flow.

## Not covered
- Google Ads Primary-conversion flags (chk-06) and GA4 key-event settings (chk-07).
- Meta, TikTok and Snapchat platform data (not in BigQuery).
- Singular sheet (not re-read this run).
- W47: not closed.
- Slack: delivery tool not allowed in this run; this file is the deliverable.

_Decision support by the Manafa BI agent. Aggregates only; no user-level data read or reported._
