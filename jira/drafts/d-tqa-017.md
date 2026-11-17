# [BE] investment_completed changed on 26 Oct: payment_method value and platform for auto-invest

- Type: Bug · Priority: Medium · Parent: ISQ-6052
- Dev Assignee: Mohammad Khubaib
- Labels: bi-agent, analytics, event-standard, tqa-017
- Tracking: tqa-017
- Status: CREATED as ISQ-6058 (approved by Amir 2026-11-17)

## Problem
From 26 Oct (mixed day, complete from 27 Oct) the backend's `investment_completed` event changed in two ways on all platforms, with no change to the event standard:
1. `payment_method` value changed from `opportunities.ewallet` to `wallet`.
2. Auto-invest investments (executed server-side) used to all carry `context.platform = web`. They now carry the user's device (ios / android / web).

## Impact
- Investment splits by platform can't be compared before and after 26 Oct. Web investments went 6,455 (week of 19 Oct) → 257 (week of 26 Oct) purely from relabelling.
- `payment_method` isn't a parameter of `investment_completed` in GA4 Event Standard v2.1, so GA4 reports using it are unofficial.
- It also distorted the GA client_id share for web (see the client_id ticket).

## Evidence (aggregated)
- 22 Oct: auto-invest investments labelled web 3,234 / 3,234.
- Web investment_completed: 6,455 (w/c 19 Oct) → 257 (w/c 26 Oct).

## What's needed (decision + small fix)
1. Confirm which release made the change (changelog around 26 Oct) and whether it was intended.
2. Decide and document the platform for **server-executed** investments: either the user's device (current) or a dedicated value such as `server` / `auto_invest`. The BI team suggests keeping platform as the user's device and relying on `is_auto_invested` (already in the backend payload) to separate server-executed investments. Make sure it's also sent to GA4 as an event parameter.
3. Either add `payment_method` (with the allowed values) to Event Standard v2.2 or stop sending it.

## Acceptance criteria
- The decision is written in the event standard. Event payloads follow it.
- A release note entry exists for the 26 Oct change, so reporting can mark the break.

## How the BI agent will verify
`bi-tracking-health` checks the platform mix and `payment_method` values on investment_completed weekly against the standard.

_Filed by the Manafa BI agent (decision support)._
