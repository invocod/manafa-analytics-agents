# 🔍 Tracking health — week 46 (9–15 Nov 2026)

Run `run-20261117-0947` · bi-tracking-health · decision support. Marks: **O** Observed · **I** Inferred.

**Verdict: 🚨 ESCALATION stands (tqa-012) · ISSUES (open, all tracked) · no new issue this run.**

**Windows:** backend judged through 11 Nov (the replica still ends on 12 Nov, partial, unchanged since 16 Nov) · GA4, Google Ads 9–15 Nov (72-hour rule: conclusions through 14 Nov) · Singular sheet to 16 Nov, checks pass.

```
🔍 Tracking health — week 46
Verdict: 🚨 ESCALATION (tqa-012 gold ≠ production, unchanged after the 17 Nov rebuild)
• [high] gold still not production — W46 Mon–Wed gold 44 inv / 73k SAR vs prod 4,113 / 15.2M (O) — data engineering
• [high] GA4 doubles 7 account events, now incl. auto_invest_disabled 2.54× (O) — ISQ-6053 (Azib)
• [med] backend replica stuck at 12 Nov; stale on 20 Nov (O) — data engineering / backend
• [med] iOS/Android GA4 degraded share creeping 4.8→6.7% / 3.6→5.5% (O) — watch, ISQ-6056
• [low] registrations Mon 9 Nov 74, below band 82–152 (O) — watch; deposits Mon–Wed 235 below 4-wk range (O)
Jira: 9 tickets open (ISQ-6053..6061) · 2 drafts awaiting approval (tqa-020, tqa-021)
Not covered: Meta, TikTok, Snapchat platform data
```

## 1. Freshness — O
Backend `mi_analytics_events` ends 12 Nov (445 events, partial), the same as yesterday: **no new production data for 5 days**. At 8 days (20 Nov) the backend becomes stale and loops must halt. GA4 and Google Ads transfers to 16 Nov. `gold` rebuilt 17 Nov.

## 2. Backend heartbeat — O
No zero days 29 Oct–11 Nov. Same-weekday band breaks: W46 only registrations Mon 9 Nov = 74 (band 82–152). Earlier ones (W45) were already explained (2 Nov auto-invest batch; 1 Nov deposits). Mon–Wed totals W42→W46: registrations 200 / 362 / 347 / 286 / **256**; KYC 400 / 544 / 504 / 541 / **402**; deposits 307 / 254 / 482 / 356 / **235** (below range); investments 1,264 / 2,839 / 1,794 / 3,204 / **4,113**.

## 3. Receipt: backend vs GA4 (9–11 Nov) — O
| Event | backend sent OK | GA4 | ratio | baseline |
|---|---|---|---|---|
| login_completed | 8,372 | 15,550 | 1.86 | 1.87 |
| withdrawal_completed | 580 | 1,088 | 1.88 | 1.88 |
| kyc_completed | 180 | 331 | 1.84 | 1.84 |
| registration_completed | 199 | 340 | 1.71 | 1.71 |
| passcode_enabled | 43 | 88 | 2.05 | 2.02 |
| bank_account_added | 46 | 88 | 1.91 | 1.80 |
| **auto_invest_disabled** | 28 | 71 | **2.54** | new |
| identity_verified | 206 | 289 | 1.40 | 1.38 |
| investment_completed / deposit_success / withdrawal_settled | | | 1.00 / 0.98 / 0.99 | ~1.0 |

auto_invest_disabled joins the doubled set (small numbers). Added to tqa-007 / ISQ-6053.

## 4. Delivery health — O
GA4 deliveries marked degraded (`no_ga_client_id`), weeks of 26 Oct / 2 Nov / 9 Nov (partial): web 64% / 63% / 54%; iOS 4.8% / 5.2% / 6.7%; Android 3.6% / 4.1% / 5.5%. No step above 10 points and no new reason. The app shares are creeping up; watch. Singular (`no_device`) mirrors GA4.

## 5. Ledger integrity — O, 🚨
| Week | gold | production |
|---|---|---|
| 26 Oct | 167 / 3.2M SAR | 3,613 / 13.7M |
| 2 Nov | 161 / 238,000 | 4,717 / 17.4M |
| 9 Nov (Mon–Wed) | 44 / 73,000 | 4,113 / 15.2M |

The 17 Nov rebuild didn't fix it. tqa-012 escalation stands: nothing may be reported from `gold`.

## 6. UTM audit and channel groups (9–15 Nov) — O
40,775 sessions; Unassigned 38.7% (baseline 40.5%), Direct 46.5%; 264 source/medium pairs. LinkedIn/Social 85 sessions (tqa-003); `paid_social` medium on linkedin 25, twitter 23, snapchat 3 lands in Paid Social; `x/(not set)` 5 in Unassigned. Placement names as source and localhost/preview referrers persist (ISQ-6060, ISQ-6061). No PII-shaped values.

## 7. Google Ads conversion actions (9–14 Nov) — O
First open Android 273 · iOS 183 · Android kyc_completed 120 (GA4 import that GA4 doubles, tqa-016) · B2B form 25. No registration action. Primary flags still need the Conversions export (chk-06).

## 8. GA4 naming (9–15 Nov) — O
633,726 events: standard 97.2% · legacy 1.1% (app_view_page_viewed, Opportunity_Details_View, Logged_in…) · Remove-list 2,140 (User_launches_the_app 1,525, Transaction_View 606) · not in standard 1.4% (passcode_submitted 6,719, withdrawal_settled 1,058, create_passcode_page_*, lead_*, w2a_*). Completion above start: kyc 1.69, withdrawal 1.85 (tqa-007).

## 9. Issues and Jira
Updated (no re-filing): tqa-003, 004, 007, 011, 012, 013, 015, 016. No new issues this run; tqa-020 and tqa-021 were filed earlier today.
**Jira:** ISQ-6053–6061 open (none fixed yet; all created today). **2 drafts awaiting approval:** `d-tqa-021` [App] Flutter screen names missing in GA4 (Azib) and `d-tqa-020` [BE] lifecycle fields count from tracking start (Khubaib).

## Missing data
Backend after 11 Nov (replica) · Google Ads Primary flags (chk-06) · Meta / TikTok / Snapchat platform data.
