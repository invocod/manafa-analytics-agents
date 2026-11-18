# [App] Stop sending the 'name' user property to GA4 (values look like users' first names)

- Type: Bug · Priority: High · Parent: ISQ-6052
- Dev Assignee: Azib Muzammil
- Labels: bi-agent, analytics, ga4, compliance, tqa-024
- Tracking: tqa-024
- Status: STAGED (awaiting approval)

## Problem
The iOS and Android apps set a GA4 user property called `name`. Its values look like people's first names.

## Evidence (aggregated, raw GA4 export `google_analytics.events_*`, 11–17 Nov)
- Set for 6,934 iOS users (807 distinct values) and 2,496 Android users (436 distinct values).
- Every value is letters only; the average length is 4.5–4.7 characters.
- The BI agent did not read the values themselves; the first-name reading is inferred from this pattern.

## Impact
Personal data in GA4 conflicts with Manafa's no-PII rule for analytics (PDPL) and Google's analytics terms. The data is also copied into the BigQuery export.

## Suggested fix
- Remove the `setUserProperty('name', …)` call (or equivalent) from the app.
- Keep only non-personal properties (IDs are fine; names, emails and mobile numbers are not).
- Ask compliance whether existing GA4 / BigQuery data needs a user-property deletion request.

## Acceptance criteria
No events in the GA4 export carry the `name` user property for a full week after the release.

## How the BI agent will verify
Weekly count of users with the `name` user property in the raw export (`bi-tracking-health`), aggregates only.

_Filed by the Manafa BI agent (decision support). Compliance review recommended._
