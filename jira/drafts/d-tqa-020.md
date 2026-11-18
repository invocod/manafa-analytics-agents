# [BE] context.lifecycle (days_since_registration, is_new_user) counts from tracking start, not registration

- Type: Bug · Priority: Low · Parent: ISQ-6052
- Dev Assignee: Mohammad Khubaib
- Labels: bi-agent, analytics, tqa-020
- Tracking: tqa-020
- Status: CREATED as ISQ-6083 (approved by Amir 2026-11-18, Command Center button)

## Problem
The backend event field `context.lifecycle` doesn't match users' real registration dates:
- `days_since_registration` never goes above 65 (as of 11 Nov), although many users registered years ago.
- `is_new_user = true` for 13,041 of the 21,785 users with events between 15 Oct and 11 Nov, while only 2,846 registered in that window.

## Impact
New- vs returning-user analysis, tenure cohorts and "days to first investment" can't use these fields. The BI dashboards exclude them for now.

## Evidence (aggregated, `mi_analytics_events`, 15 Oct – 11 Nov)
Max `days_since_registration` per platform: iOS 65, Android 64, web 54. `is_new_user` true for 13,041 users vs 2,846 registrations.

## Likely root cause (inferred)
The value is computed from the user's first analytics event (tracking went live around early September), not from the account's registration date.

## Suggested fix
Compute `days_since_registration` from the profile/user creation date and `is_new_user` from a defined rule (e.g. registered within the last 7 days). Document both in the event standard.

## Acceptance criteria
`days_since_registration` matches the account's creation date for a sample of long-standing accounts, and the `is_new_user` share among active users is in line with recent registrations.

## How the BI agent will verify
Weekly distribution of `lifecycle.days_since_registration` and the `is_new_user` share vs registrations (`bi-tracking-health`).

_Filed by the Manafa BI agent (decision support)._
