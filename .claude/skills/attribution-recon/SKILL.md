---
name: attribution-recon
description: "Weekly attribution reconciliation: backend events as the one conversion ledger, Singular vs GA4 vs ad-platform claims explained against it, first-touch and last-touch side by side, honest allocation with confidence levels. Never sums across platforms, never forces numbers to tie out."
---

# Attribution Reconciliation Loop

Answer "which channels actually drive registrations, deposits, investments?" without letting any platform grade its own homework. Read `CLAUDE.md` and `context/` first; state in `state/attribution-recon.json` + `.log`.

> **Interim data (until BigQuery):** the ledger (step 1) is the GA4 key-event counts from `data/exports/ga4/`; claims come from Singular (`data/exports/singular/`) and Google Ads (`data/exports/google-ads/`). Meta/TikTok/Snapchat are not configured — leave their columns out rather than empty. Every readout footnotes that the ledger is the GA4 interim proxy, not the backend itself.

| Part | Spec |
|---|---|
| **Check cadence** | Weekly (Monday, after tracking-QA; skip if tracking-QA escalated — reconciliation on broken tracking is fiction) |
| **Acts when** | Always produces the readout; flags channels where sources *disagree in direction* or a claim ratio broke its usual band |
| **Purpose** | One defensible, consistent read of channel performance for budget decisions |
| **Stop / bail-out** | A required source stale/unreachable → publish with that column marked "stale", never extrapolate. Never turn a platform-vs-GA gap into a credit multiplier. |
| **Output** | Attribution readout (format below) to Slack + `reports/` |

## Loop body

1. **Ledger first.** Last closed week (Mon–Sun, excluding trailing 72h): backend counts of `registration_completed`, `deposit_success`, `investment_completed`. This row is *the* conversion count.
2. **Claims table.** For the same window, same conversion definition: GA4 key events by channel, Singular conversions by source, each ad platform's claimed conversions (from exports). Note each source's attribution window — differences explain gaps, so name them.
3. **De-dupe and explain.** Sum of claims vs ledger: report "platforms claim N, backend verified M". The delta = over-claiming + view-through + untracked. Never allocate more conversions than the ledger holds.
4. **First-touch vs last-touch side by side** (GA4 first-user vs session scope; Singular install-source vs event-session). The gap per channel is the insight — a channel strong on first-touch and weak on last-touch is creating demand others close (expect this for creators/Snapchat).
5. **Blind-spot read.** Direct + branded-search share: if large and growing, the likely story is working top-of-funnel that tracking can't see (creators, word of mouth, AI assistants) — confirm direction with the custom channels before concluding. Flag, don't guess.
6. **Trend verdicts.** Per channel: ⬆/➡/⬇ only where sources *agree in direction*; "disputed" where they don't. Recommendations ride on direction + ledger, never on one platform's absolute claim.

## Self-check

Same window, same conversion event, same time zone in every column? Any column inside its conversion lag? Did a tracking-QA issue touch a channel this week (if so, mark that channel "measurement suspect")?

## State

```json
{"cursor": "<last week reconciled>", "claim_ratio_bands": {"meta_vs_backend_reg": [1.1, 1.6]}, "weekly_snapshots": "reports/"}
```

Claim-ratio bands learn over time: after 4+ weeks, a platform's claims/backend ratio has a normal band; alert only when it leaves the band.

## Output format (Slack summary + full readout in `reports/`)

```
🧭 Attribution readout — week <ww>
Ledger (backend): reg X | dep Y | inv Z  (platforms claim: N reg — gap normal/⚠)
| Channel | Backend-attributed | GA4 LT | GA4 FT | Singular | Platform claim | Read |
Disputed: <channels where sources disagree in direction>
Blind spots: direct+branded = __% (trend)
Recommendation: <allocation call with confidence: high/med/low> — for human decision, not auto-applied
```
