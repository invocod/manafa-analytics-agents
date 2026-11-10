---
name: weekly-ads-check
description: "Weekly paid-media review across Google Ads, Meta, TikTok, Snapchat (from CSV exports): fixed-order check of spend → traffic → conversions → creative → landing → tracking, ending in exactly one call per account: HOLD, FIX, TEST, or INVESTIGATE. Stages plans; never touches live accounts."
---

# Weekly Ads-Check Loop

Make the weekly account review end in one decision per account. Read `CLAUDE.md`, `context/manafa-marketing.md` (targets, floors, spend cap) first; state in `state/weekly-ads-check.json` + `.log`.

> **Interim data (until BigQuery):** the only active account is **Google Ads** (`data/exports/google-ads/`); "backend-verified conversions" means the GA4 interim ledger (`data/exports/ga4/`). Meta/TikTok/Snapchat appear in the report only as "not configured". Landing-page and creative checks run only on what the CSV columns support.

| Part | Spec |
|---|---|
| **Check cadence** | Weekly (Monday) |
| **Acts when** | A metric moves outside the account's trailing 6–8 **week** range (not just the prior 7 days), moves the same way 3+ weeks, or crosses a target in the context doc. Spend-cap breaches, tracking problems, and broken landing pages act immediately, no range check. |
| **Purpose** | One decision per account per week |
| **Stop / bail-out** | **Never change budgets, bids, campaign status, tracking, or live ads.** All changes are staged plans for human approval. Halt + escalate if spend passes its cap. An account with no export fresher than 8 days gets verdict INVESTIGATE: "stale data". |
| **Output** | One HOLD / FIX / TEST / INVESTIGATE call per account, with facts, hypotheses, and missing data |

## Loop body

1. Read targets, hard floors, conversion definitions from `context/manafa-marketing.md`; read fresh exports from `data/exports/<platform>/`.
2. Per account, check **in this fixed order**: spend & pacing → traffic (clicks, CPC, CTR, CPM) → conversions (CVR, CPA vs backend-verified conversions — platform-claimed CPA and backend CPA side by side) → creative fatigue (frequency, CTR vs its peak) → landing pages (do campaign URLs resolve, with correct UTMs per the convention) → tracking (platform conversions vs backend, verdict bands from `CLAUDE.md`).
3. Compute from the row-level CSVs (compute, don't eyeball); compare each metric to its trailing 6–8 week range from state snapshots.
4. For each mover: facts vs hypotheses vs missing data, explicitly separated.
5. **End with exactly one call per account**: HOLD (no change) / FIX (known, named issue — staged plan attached) / TEST (hypothesis worth spend — brief attached) / INVESTIGATE (the data can't be trusted yet — name the one check that would settle it).

## Self-check

Does any recommendation rest on a number inside its conversion lag or a campaign still in learning phase? If platform-vs-backend disagree beyond the usual gap, the call is INVESTIGATE, not FIX. Were any week's conversions compared against a different week's spend (window mismatch)?

## State

```json
{"cursor": "<last week reviewed>", "weekly_snapshots": {"google": {}}, "calls": [{"week": "2026-W46", "account": "meta", "call": "FIX", "issue": "..."}], "staged_fixes": []}
```

Don't re-open a FIX already staged and awaiting approval; chase its approval instead.

## Slack output

```
📊 Weekly ads check — week <ww>  (spend: X SAR of cap Y)
| Account | Call | Why (one line) |
Staged for approval: <fix plans>
Missing data: <stale platforms, unexported accounts>
```
