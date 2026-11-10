---
name: campaign-postmortem
description: "Event-based campaign postmortem: when a Manafa campaign (offering launch, promo, seasonal push) concludes, capture results vs goals, lessons, and reusable assets so each campaign compounds. One postmortem per campaign, triggered manually or by the weekly review noticing a campaign ended."
---

# Campaign-Postmortem Loop

Capture what a finished campaign actually taught us. Event-based — run on demand (`/campaign-postmortem <campaign>`) or when the weekly review notices a campaign/offering push concluded. Read `CLAUDE.md` and `context/` first; state in `state/campaign-postmortem.json` + `.log`.

| Part | Spec |
|---|---|
| **Check cadence** | On campaign end (event-based; no cron) |
| **Acts when** | A campaign concluded that has no postmortem in state |
| **Purpose** | Results, lessons, reusable assets — so campaigns compound instead of repeating |
| **Stop / bail-out** | No concluded campaign → skip. Campaign still inside its conversion lag → wait (set a reminder date in state) rather than judging early. |
| **Output** | Postmortem doc in `reports/postmortems/<campaign>.md` + Slack summary + proposed learnings |

## Loop body

1. **Define the campaign window and goals** (from the brief if one exists; otherwise reconstruct from `utm_campaign` values and ask for goals in the output's open questions).
2. **Pull final results vs goals** over the full window + the conversion-lag tail: spend (exports), traffic (GA4 by the campaign's UTMs), backend conversions attributed to the campaign (first-touch and last-touch, side by side — per `CLAUDE.md` the backend count is the ledger).
3. **Compute efficiency** with matched windows: full-window spend over full-window+lag conversions, stated explicitly.
4. **What worked / what didn't / why** — conclusions must be supported by the data; separate correlation from cause, and say which is which. Hindsight narrative is the named failure mode.
5. **Save reusable assets**: winning creative angles, copy, audiences, UTM patterns — listed with their evidence.
6. **Feed forward**: experiment ideas → weekly review backlog; lessons that will still hold next quarter → proposed Learnings rows for `context/manafa-marketing.md` (human-approved, never auto-written).

## Self-check

Is the window closed including conversion lag? Are "wins" above what the channel's baseline would have produced anyway (compare to a matched non-campaign period)? One postmortem per campaign — check state.

## State

```json
{"completed": ["ramadan-2026"], "pending_lag": [{"campaign": "sukuk-x-launch", "ready_on": "2026-12-01"}]}
```

## Output format

```
🧾 Postmortem — <campaign>
Goal: … → Result: … (vs goal: hit/miss by __)
Spend X SAR → reg A / dep B / inv C (backend; FT vs LT: …)
Worked: … (evidence) | Didn't: … (evidence) | Unknown: …
Reusable: … | Proposed learnings: … | Open questions: …
```
