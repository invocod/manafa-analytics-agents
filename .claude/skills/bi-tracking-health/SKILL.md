---
name: bi-tracking-health
description: "Weekly tracking-health loop: backend event heartbeat, backend-vs-GA4 and backend-vs-Google-Ads receipt, delivery health, UTM and channel audit, Google Ads conversion actions, GA4 naming vs Event Standard v2.1. Runs first every week; every other loop depends on it."
---

# Tracking-Health Loop

Keep the measurement layer trustworthy. State: `state/bi-tracking-health.json` + `.log`.

| Part | Spec |
|---|---|
| **Cadence** | Weekly (Monday, first), and on deploy / campaign launch |
| **Acts when** | An event is missing/zero/out of band, a receipt ratio leaves its baseline band, delivery degradation steps up, UTMs break the convention, or naming drifts from the standard |
| **Stop / bail-out** | Healthy → log "clean", one ✅ line in the weekly digest. **A broken backend conversion event or a corrupted ledger escalates immediately.** Recommend only; never change tracking config. |
| **Output** | Report with prioritized issues, each marked Observed / Reported / Inferred |

## Before every run (all bi-* loops)

1. Read `CLAUDE.md`, `context/metrics.md` and this loop's `state/<loop>.json`.
2. Run `sql/readonly/source_freshness.sql`. Use only complete days: the backend replica's newest day is usually partial, and the trailing 72 hours are never judged. A source older than 8 days is **stale**: report "stale data — <source>", do not advance the cursor, halt if it is a required source.
3. BigQuery only (`databases-472111`, me-central2), read-only (`execute_sql_readonly`). Build numbers from `context/metrics.md` definitions and `sql/readonly/` queries; aggregated output only. `gold`/`silver`/`curated`/`reporting`/`dashboard_views`/`sama_mart` are suspended (tqa-012).
4. Not in BigQuery = **not configured** (Meta, TikTok, Snapchat platform data, GA4 platform split). Name them under "Not covered"; never estimate them. **Exception: Singular** is read from its Google Sheet per `context/singular-sheet.md` (validate first; own "Singular (attribution)" section; never blended).
5. After the run: write the report to `reports/<yyyy>/W<ww>/`, update state, append one log line (plus `decision:` lines), commit.
6. Report the run live to the Command Center exactly as `docs/command-center.md` says: statuses and steps as they actually happen, never estimated.

## Loop body

1. **Backend heartbeat** (`backend_events_daily.sql`): daily registration, kyc, deposit, investment for the last complete 14 days. Flag zero days and days outside the same-weekday band (method in `context/metrics.md`; bands in `state/bi-daily-kpi-watch.json`, history from 2026-10-02). Zero on a money event = escalate.
2. **Receipt: backend vs GA4** (`backend_events_daily` + `event_delivery_health_daily` + `ga4_events_daily`), same closed days: GA4 count ÷ backend sends that succeeded, per event. Compare to `baselines.bigquery_*.ga4_over_backend_sent_ok`. A ratio moving > ±0.15 from baseline, a new event near 2.0, or a money event leaving 0.95–1.05 = issue.
3. **Delivery health** (`event_delivery_health_daily.sql`): degraded share per platform × vendor, weekly. A step change of > 10 points, or a new `degraded_reason`, = issue.
4. **Ledger integrity**: production events vs any secondary layer someone reports from (currently `gold`, tqa-012). Re-check the tqa-012 signature weekly until resolved.
5. **UTM audit** (`ga4_traffic_daily.sql`, full last week): values outside `context/utm-convention.md` (case, separators, mediums), Unassigned share vs baseline, deep-link names as source, localhost/preview/debug referrers, PII-shaped values (`@`, 9+ digits) = escalate.
6. **Channel groups**: custom mediums (creator, newsletter, podcast, community, referral-program) land in their channels; paid social arrives tagged.
7. **Google Ads conversion actions** (`gads_conversions_daily.sql`; playbook `context/playbooks/google-ads-conversion-audit.md`): which actions count in Conversions (Primary), whether a GA4-imported action that GA4 doubles (tqa-007) is bidding, whether the intended action (registration) exists. Primary flags not in the transfer = Unknown, not a failure.
8. **GA4 naming** (`ga4_events_daily.sql` vs `context/ga4-event-standard-v2.1.csv`; playbook `ga4-event-standards.md`): share of standard / legacy / Remove-list / not-in-standard events; completion > start signatures.
9. **Diff against open issues**: update existing issues (append `update_<date>`), never re-file. New issues get id, severity, owner suggestion, and the single next check that would confirm the fix.

## Jira hand-off (squad-owned issues → ISQ-6052)
Follow `docs/jira.md`. For each open issue whose owner is backend, mobile or web (not in `jira.outside_squad`): if no draft or ticket exists, write a staged draft (prefix, Dev Assignee by area, full description template, aggregated evidence only). If a ticket exists, check its fix criterion and, when it passes, stage a "verified fixed by data" comment. First sync decisions Amir made with the Approve / Reject buttons in the Command Center (`jira_drafts` status `created` / `rejected`) into `jira/drafts/drafts.json` and `jira.tickets`, as `docs/jira.md` describes; never re-file a rejected draft unless the issue materially changed. The agent itself never creates, edits or comments in Jira without Amir's approval (chat, or his button press in the Command Center). Report staged drafts in the output under "Jira: N drafts awaiting approval".

## Self-check
Expected change (deploy, campaign end, intended rename)? Same days and timezone on both sides of every ratio? Unknown ≠ failure.

## Slack / chat output
```
🔍 Tracking health — week <ww>
Verdict: CLEAN | ISSUES (n) | 🚨 ESCALATION
• [sev] finding — evidence (O/R/I) — suggested fix — owner
Not covered: <sources>
```
