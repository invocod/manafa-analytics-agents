# 🧾 Campaign health — check of 19 Nov 2026

Run: run-20261119-0853 · bi-campaign-health · started from the local Command Center
**Verdict: no campaign concluded; no postmortem due. national_day_96 stays blocked (no goals, no spend source for 20 Sep–4 Oct).**

## Active campaigns (Observed)
- Google Ads (BigQuery `CampaignBasicStats`): Minto | Above 5Mn 577.61 SAR, Minto | App promotion - IOS | App installs 389.05, Minto | App installs - Android 395.30 on 18 Nov. All ENABLED.
- Singular sheet (gate passed, data to 18 Nov): TikTok Ads iOS 1,077.00 SAR and Twitter iOS 999.66 SAR on 18 Nov, so both keep spending.
- Backend campaign tags: replica unchanged since 17 Nov (tqa-023), so the 18 Nov reading stands (minto_manafa_b2b active, minto_manafa_b2c sporadic).

## national_day_96 (blocked)
```
🧾 Campaign health — national_day_96
Goal → Result | goals not on record | spend: not available (Google Ads in BigQuery from 7 Nov, Singular sheet from 11 Oct; X/Snapchat not configured)
Backend floor to 16 Nov (attributed via acquisition_campaign OR last_campaign; coverage ~1.5% in window, tqa-014): reg 21 / dep 13 (6 users) / inv 98 (10 users)
Worked: unknown | Didn't: unknown | Reusable: none evidenced | Proposed learnings: none | Open questions: goals; spend by platform; cq-001
```
- Floor to 16 Nov equals the floor to 15 Nov (no attributed events on 16 Nov).
- cq-001: the investment count to 11 Nov reproduces as **96** today, same as 18 Nov. The 116 from 16 Nov is still unexplained (Unknown; open for tracking-QA).
- Efficiency can't be computed: there is no spend for the window, and a cost per result would need matched spend and lag windows.

## Not covered
Meta, TikTok, Snapchat and X platform data (not in BigQuery); Singular conversion events. Slack: not allowed in this run.

_Decision support by the Manafa BI agent. Aggregates only._
