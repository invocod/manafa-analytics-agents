# Campaign health — national_day_96 (readiness note, not a postmortem)

**Status: PENDING — can't be evaluated fairly yet.** Run: run-20261116-1654 (2026-11-16). Marks: **O** = Observed, **I** = Inferred.

## Why this campaign
- O: no campaign ended last week. The three Google Ads campaigns with spend (Minto | Above 5Mn, App promotion iOS installs, App installs Android) are all ENABLED and serving.
- O: `national_day_96` (Saudi National Day push, utm sources X and Snapchat, 1 Google Ads tag) has no attributed registrations after the week of 28 Sep, so it has concluded, and its 14-day lag window has closed. No postmortem exists for it.

## What can be measured (backend, attributed only; a floor, not a total)
| | Registrations | Deposits | Investments |
|---|---|---|---|
| X | 19 | 10 | 63+ |
| Snapchat | 1 | 2 | 12 |
| Google Ads tag | 1 | 0 | 0 |
| **Total** | **21** (weeks of 21–28 Sep) | **12** (to 11 Nov) | **116** (to 11 Nov) |

Investments are counted per event, so repeat investments by the same attributed users are included.

## Blockers (each must close before a verdict)
1. **Goals**: no brief or targets on record. Owner: marketing.
2. **Spend**: X and Snapchat spend aren't in BigQuery (Phase 2, B4). Without it there's no cost per registration or deposit.
3. **Attribution coverage**: only ~5% of backend registrations carry `acquisition_*` (tqa-014), so the campaign's true reach is unknown.
Also: the backend log before 2 Oct contains a launch burst (Sep 20–Oct 1), so a matched pre-campaign baseline isn't reliable.

## Open questions for marketing
- What were the goals (registrations, deposits, budget)?
- What was spent on X and Snapchat, by day?
- Were there creators or other placements without UTMs?
