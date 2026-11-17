# [BE] attribution.last_* is a copy of acquisition_* — record the real last touch at conversion

- Type: Improvement · Priority: Medium · Parent: ISQ-6052
- Dev Assignee: Mohammad Khubaib
- Labels: bi-agent, analytics, attribution, tqa-019
- Tracking: tqa-019
- Status: STAGED (awaiting approval)

## Problem
On 1,026 of 1,038 attributed registration, deposit and investment events since 7 Sep (98.8%), `attribution.last_source/medium/campaign` is identical to `acquisition_*`. The backend has no real last-touch.

## Impact
Manafa can't see which channel *closes* deposits and investments (e.g. a retargeting campaign or an email) as opposed to which one *acquired* the user. First- vs last-touch, the core of the weekly attribution readout, can only be read from GA4 sessions. GA4 isn't the conversion ledger.

## Evidence (aggregated)
`mi_analytics_events`, events with a non-empty `acquisition_source`, 7 Sep – 11 Nov: 1,038 attributed, 12 where last_* differs from acquisition_*.

## Likely root cause (inferred)
The `last_*` fields are filled from the same stored profile attribution as `acquisition_*`. They aren't filled from the source of the session or request in which the conversion happened.

## Suggested approach
- Keep `acquisition_*` = first touch, stored once on the profile.
- Set `last_*` from the most recent tagged visit before the event: UTMs, gclid or deep-link params on the current session, saved on the profile with a timestamp; fall back to `direct`.
- Add `last_touch_at` so a lookback window (e.g. 30 days) can be applied in reporting.

## Acceptance criteria
- `last_*` differs from `acquisition_*` where the user came back through a different tagged link (QA test: register via link A, return via link B, deposit; the deposit event shows A as acquisition and B as last).
- Documented in the event standard.

## How the BI agent will verify
Share of attributed events where last ≠ acquisition (expected well above 1.2% once live), checked weekly.

_Filed by the Manafa BI agent (decision support). Depends on the [BE] attribution-coverage ticket._
