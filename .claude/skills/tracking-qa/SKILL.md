---
name: tracking-qa
description: "Weekly tracking-QA loop: verify Manafa's key events fire, UTMs follow the convention, GA4 channel grouping works, and backend-vs-platform conversion counts stay inside normal bands. Run weekly, and on deploy or campaign launch. Every other loop depends on this one."
---

# Tracking-QA Loop

Keep the measurement layer trustworthy. Read `CLAUDE.md` and `context/` first; state lives in `state/tracking-qa.json` + `.log`.

> **Interim data (until BigQuery):** all checks read CSVs — GA4 (`data/exports/ga4/`, the interim ledger), Singular, Google Ads. "Backend counts" below means the GA4 key-event counts. The backend-vs-GA4 receipt check is suspended (GA4 can't audit itself); the receipt checks that remain are **GA4 vs Singular** and **GA4 vs Google Ads claims**. Checks whose columns aren't in the dropped CSVs are reported "not covered", never guessed.

| Part | Spec |
|---|---|
| **Check cadence** | Weekly (Monday, before the weekly review), and on deploy / campaign launch |
| **Acts when** | Events missing/misfiring, UTMs violating the convention, conversions failing to attribute, or a backend-vs-platform gap outside verdict bands |
| **Purpose** | Every other loop is blind if this one fails |
| **Stop / bail-out** | All healthy → log "clean", post nothing except a one-line ✅ in the weekly review. **A broken backend conversion event escalates to Slack immediately.** Recommend fixes only — never change tracking config. |
| **Output** | Tracking-QA report: prioritized fixes, each marked Observed/Reported/Inferred |

## Loop body

1. **Backend events heartbeat.** Pull daily counts of `registration_completed`, `kyc_completed`, `deposit_success`, `investment_completed` for the last 14 days (excluding trailing 72h). Flag: any day at exactly zero, or a day outside ±3σ of the same weekday's trailing 8-week values. Zero on a revenue event = escalate now.
2. **Platform receipt check.** Compare last closed week's backend counts against what GA4 key events and each fresh ad-platform export report for the same window. Apply the verdict rules in `CLAUDE.md`: 10–30% gap normal; >40%, zero, direction flip, or a stable gap suddenly changing = INVESTIGATE. A tag firing is not a conversion arriving — check the destination's number, not the send.
3. **UTM audit.** Pull last week's GA4 sessions by source/medium/campaign. Flag: values not in `context/utm-convention.md` (case variants, separators, duplicate spellings), anything in **Unassigned** above 5% of sessions (name the top offending source/mediums), and any UTM value containing `@`, digits-only strings 9+ long, or anything PII-shaped — escalate PII in UTMs immediately.
4. **Channel-group check.** Verify `creator`, `newsletter`, `podcast`, `community` mediums land in their custom channels, not Unassigned; verify Snapchat traffic is arriving tagged.
5. **Diff against open issues** in state; update existing issues rather than re-filing. New issues get an id, severity, owner suggestion, and the single next check that would confirm the fix.

## Self-check

Before flagging: is it truly broken, or an expected change (campaign ended, offering closed, deploy renamed an event intentionally)? Confirm against the known-causes calendar and last run's baseline. An unknown (couldn't check) is reported as unknown — it never counts as a failure.

## State

```json
{"cursor": "<last audited week>", "open_issues": [{"id": "tqa-012", "found": "...", "severity": "high", "status": "open"}], "baselines": {"unassigned_share": 0.04}}
```

## Slack output format

```
🔍 Tracking-QA — week <ww>
Verdict: CLEAN | ISSUES (n) | 🚨 ESCALATION
• [severity] finding — evidence (Observed/Inferred) — suggested fix — owner
Data gaps: <sources stale/unreachable>
```
