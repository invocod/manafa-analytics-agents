# bi-tracking-health — week W46 (Mon 9 – Sun 15 Nov 2026)

**Verdict: 🚨 ESCALATION + ISSUES (5 new, 8 updated)**
First run on BigQuery (read-only, me-central2). It re-baselines everything; earlier CSV-era baselines are superseded.
Run: 2026-11-16, Riyadh tz. Judged window for conversions: **9–11 Nov** (72-hour rule, and the backend replica is complete only through 11 Nov; 12 Nov is partial).
Marks: **O** = Observed (queried), **I** = Inferred (reasoned), **R** = Reported (by a person).

## 🚨 Escalation
**tqa-012 [HIGH] — `gold` (and anything built on it) reflects the STAGING environment, not production.**
- O: `gold.fact_investment`, week of 2 Nov: **161 investments / 238,000 SAR**. `stg_staging_financing.mi_analytics_events` same week: **161 / 238,000 SAR** (identical). Production `manafa_financing` same week: **4,717 / 17,448,000 SAR**.
- O: ID ranges: `gold` profiles ≤ 610,975 and `stg_staging_financing` ≤ 610,979; production registrations use profiles 614,252–625,236. **0 of 2,790** production registrants (12 Oct – 8 Nov) exist in `gold`.
- O: `gold` matched production volumes in the week of 12 Oct (2,120 investments) and fell to staging-sized volumes from the week of 19 Oct.
- I: the DWH pipeline that builds `silver/curated/gold` has read the staging source since about 19 Oct.
- Impact: any dashboard, Looker Studio page or report that reads `gold`, `reporting`, `dashboard_views` or `sama_mart` may show staging numbers. **Compliance/regulatory review recommended** if any SAMA reporting reads these layers.
- Owner: data engineering (DWH). Next check: confirm the source connection of the gold build (etl_logs / pipeline config).
- Decision for loops: **the conversion ledger is production `manafa_financing.mi_analytics_events`**. `gold` is suspended for all loops until tqa-012 is resolved.

## Checks

### 1. Backend heartbeat — ✅ clean
O: every day 9–11 Nov is inside its same-weekday band (mean ± 3σ, 5 prior weeks since 2 Oct), and no event read zero.

| Event (prod backend) | Mon 9 | Tue 10 | Wed 11 | Week 2–8 Nov |
|---|---|---|---|---|
| registration_completed | 74 | 97 | 85 | 634 |
| kyc_completed | 140 | 136 | 126 | 1,118 |
| deposit_success | 89 | 77 | 69 | 646 |
| investment_completed | 1,200 | 1,729 | 1,184 | 4,717 |

Weekly totals were cross-checked two ways (SQL and script) and match.
O: `kyc_completed` is not a new-user step. Of 1,118 profiles that completed KYC in 2–8 Nov, only 419 (37%) have a `registration_completed` since 7 Sep. Funnel loops must cohort it, never divide KYC by registrations.

### 2. Platform receipt — ⚠️ tqa-007 confirmed against backend truth
Backend vs GA4 (Data Transfer), 6–11 Nov:

| Event | Backend | Sent to GA4 OK | GA4 count | GA4 ÷ sent-OK |
|---|---|---|---|---|
| login_completed | 15,484 | 14,957 | 27,919 | **1.87** |
| withdrawal_completed | 843 | 807 | 1,517 | **1.88** |
| kyc_completed | 838 | 380 | 699 | **1.84** |
| registration_completed | 532 | 420 | 719 | **1.71** |
| passcode_enabled | 109 | 95 | 192 | **2.02** |
| bank_account_added | 94 | 90 | 162 | **1.80** |
| identity_verified | 1,632 | 431 | 596 | 1.38 |
| investment_completed | 4,974 | 4,256 | 4,247 | 1.00 ✅ |
| deposit_success | 427 | 399 | 395 | 0.99 ✅ |
| withdrawal_settled | 847 | 811 | 806 | 0.99 ✅ |
| auto_invest_enabled | 576 | 223 | 225 | 1.01 ✅ |

- O: the backend logs **exactly one** GA4 delivery per event, with one attempt (0 multi-sends across 23,098 events checked). The backend dispatcher is not the double sender.
- R (12 Nov, mobile team): legacy client-side firing was removed from the app.
- I (new leading hypothesis): a second sender forwards the same events into GA4. The likeliest is **Singular's GA4 partner forwarding** (Singular was connected to GA4 in Oct and receives these events by S2S); only events mapped there are doubled. Next check: Singular → Partner configuration → Google Analytics 4 → event mapping. If it lists login/registration/kyc/withdrawal_completed/passcode/bank_account but not deposit/investment, this is confirmed.

### 3. UTM audit — ⚠️ persistent violations
O, GA4 sessions 9–15 Nov: **41,746**. Unassigned **40.5%** (16,813 are `(not set)/(not set)`); Direct **45.1%**. Flag threshold is 5%.
- tqa-003 persists: `LinkedIn / Social` 85 sessions (case and medium); `paid_social` medium on linkedin, twitter, snapchat and `google_ads` (140 sessions); the convention says `cpc`.
- tqa-004 persists: deep-link names as utm_source: `send_message_to_scf_borrower` 33, `download_app_modal` 19, `article` 9, plus `invite_a_friend`, `mid_page`, `x`.
- **New tqa-015**: developer/preview traffic in the production property: **202 distinct `127.0.0.1:<port>` referrers**, `*.netlify.app` previews and `tagassistant.google.com`, 242 sessions/week in total.
- O: no PII-shaped values (`@`, 9+ digit strings) in source/medium. ✅

### 4. Channel groups — ⚠️
O: 0 sessions with `creator`, `newsletter`, `podcast`, `community` or `referral-program` mediums this week (custom channels can't be verified without traffic). Snapchat 3 sessions; TikTok/Meta 0 (tqa-002 persists; Singular not configured in BigQuery, so app-side paid social can't be confirmed).

### 5. Delivery health (new check) — ⚠️ tqa-013
O, GA4 deliveries marked `degraded` (reason `no_ga_client_id`) by platform:

| Week of | web | iOS | Android |
|---|---|---|---|
| 5 Oct | 45.6% | 6.7% | 4.9% |
| 19 Oct | 42.9% | 4.7% | 3.0% |
| **26 Oct** | **64.0%** | 4.8% | 3.6% |
| 2 Nov | 63.2% | 5.2% | 4.1% |
| 9 Nov (partial) | 54.4% | 6.7% | 5.5% |

O: step change in the week of 26 Oct. On 6–11 Nov, degraded share by event: identity_verified 74%, auto_invest_enabled 61%, kyc_completed 55% (all web-heavy). Degraded deliveries do not appear in GA4 (money events match sent-OK, not backend totals).
I: the web app stopped passing the GA client_id to the backend for most server-fired events around 26 Oct (deploy?). Owner: web frontend + backend.

### 6. Google Ads conversion actions — ⚠️ tqa-016 (partial)
O, conversions 7–12 Nov: iOS First open 194; Android First open 261 (all attribution types); **Android `kyc_completed` (GA4-imported) 110**; web `above-5-b2b-b2g-ar-success` 29.
- I: `metrics.conversions` counts only actions included in Conversions (Primary), so the GA4-imported `kyc_completed` is very likely a **bidding conversion**. GA4 doubles this event (tqa-007), so Google Ads optimizes on inflated KYC.
- O: no `registration_completed` action appears. That contradicts `context/manafa-marketing.md` ("all platforms optimize on registration_completed"). Confirm and correct the doc.
- Coverage: Primary/Secondary flags are not in the transfer, so they're unconfirmed (still need the Conversions → Summary screen).

### 7. GA4 naming vs Event Standard v2.1 — ⚠️ improving
O, 9–15 Nov: standard names 97.2% of events; **legacy names 1.2%** (55 names, 7,318 events; top: app_view_page_viewed, Opportunity_Details_View, Logged_in); **Remove-list 1,563** (User_launches_the_app 1,517); **not in standard 1.4%** (15 names, 9,120: passcode_submitted 6,712, withdrawal_settled 1,058, create_passcode_page_*, lead_submitted, lead_completed, w2a_*).
- tqa-009 trend: legacy share down (CSV era 1.8–5.6%); User_launches_the_app ≈1.5k/week vs ≈2.4k/week before. Withdrawal_Click = Withdrawal_Success still identical (98 = 98).
- tqa-007 signature persists in GA4: kyc_completed 732 > kyc_started 434; withdrawal_completed 2,022 > withdrawal_started 1,091.
- Key-event list and counting method: not in BigQuery, still pending (tqa-010).

## New / updated issues
| id | sev | what | owner | next check |
|---|---|---|---|---|
| **tqa-012** | **HIGH** | gold/DWH built from staging since ~19 Oct | Data eng | gold build source connection |
| tqa-007 | high | 7 events ~1.7–2.0× in GA4; backend sends once → second sender (Singular→GA4 forwarding?) | Analytics (Singular config) | Singular GA4 partner event mapping |
| **tqa-013** | med | web events without GA client_id: 44% → 64% from week of 26 Oct | Web + backend | deploys around 26 Oct; client_id handoff on web |
| **tqa-014** | med | backend events carry acquisition data on ~5% of registrations, ~1% of deposits | Backend | where attribution JSON is populated |
| **tqa-016** | med | Google Ads bids on GA4-imported (doubled) Android kyc_completed; no registration action | Paid / Analytics | Conversions → Summary (Primary flags) |
| **tqa-015** | low | localhost/preview/tag-assistant traffic in prod GA4 | Web | internal-traffic filter; dev builds off the prod measurement ID |
| tqa-001 | low | no-source sessions 85.6% (Unassigned 40.5% + Direct 45.1%) | — | needs raw GA4 export (platform split) |
| tqa-003/004/009/011 | med/med/low/low | persist (see checks 3 and 7) | — | — |

## Data gaps / not covered
- GA4 transfer has no stream/platform column, so QA streams can't be excluded and web/app can't be split. Needs the raw GA4 export in me-central2.
- Singular, Meta, TikTok and Snapchat are not in BigQuery (not configured).
- Backend replica ends partway through 12 Nov (about 4 days of lag).
- tqa-005 (IDs in page titles): not re-checked this run.
