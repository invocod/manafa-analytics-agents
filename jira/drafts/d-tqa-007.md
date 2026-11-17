# [App] GA4 counts 6 account events twice — check Singular → GA4 event forwarding

- Type: Bug · Priority: High · Parent: ISQ-6052
- Dev Assignee: AzibMuzammil
- Labels: bi-agent, analytics, tqa-007
- Tracking: tqa-007
- Status: STAGED (awaiting approval)

## Problem
GA4 receives about twice as many `registration_completed`, `kyc_completed`, `login_completed`, `withdrawal_completed`, `passcode_enabled` and `bank_account_added` events as the backend actually sends. Money events (`deposit_success`, `investment_completed`, `withdrawal_settled`) are **not** doubled.

## Impact
- Every GA4 report and exploration overstates registrations (~1.7×) and KYC (~1.8×), so funnel conversion rates in GA4 are wrong.
- Google Ads imports the Android `kyc_completed` key event from GA4 and bids on the doubled count (see tqa-016).

## Evidence (aggregated, BigQuery)
- GA4 count ÷ backend deliveries marked `succeeded` (week of 9 Nov): login 1.87 · withdrawal_completed 1.88 · kyc_completed 1.84 · registration_completed 1.71 · passcode_enabled 2.02 · bank_account_added 1.80 · identity_verified 1.38 · money events 0.99–1.01.
- The backend sends **exactly one** GA4 hit per event: 0 multi-sends out of 23,098 deliveries (`mi_analytics_event_deliveries`). The backend's GA4 sender is not the duplicate source.
- The mobile team confirmed on 12 Nov that the app no longer fires these events client-side.
- The backend also sends every one of these events to **Singular** (2–11 Nov, e.g. login iOS 18,838, withdrawal_completed iOS 1,073, withdrawal_settled iOS 1,007), in the same proportions as the money events.
- `withdrawal_completed` is doubled in GA4 but `withdrawal_settled` is not, although the backend sends both to GA4 and Singular the same way. So the duplication is **per event**, which points to a per-event configuration.

## Likely root cause (inferred — please confirm)
1. **Most likely:** Singular's partner integration with GA4 (Singular → Partner Configuration → Google Analytics 4) has these six events mapped for forwarding. Singular then re-sends them to GA4 on top of the backend's direct send. Money events aren't mapped, so they aren't doubled.
2. Less likely: an older app version still in use fires these events through the Firebase SDK.

## Where to look
- Singular dashboard → Partner Configuration → Google Analytics 4 (app and web): the event mapping / postback list. Admin access may sit with marketing.
- GA4 DebugView on a test device: register or log in once and count `login_completed` hits plus their source (`firebase` SDK vs Measurement Protocol).

## Acceptance criteria
- Each of the six events reaches GA4 once per backend event: GA4 ÷ backend `succeeded` deliveries is between 0.9 and 1.1 for a full week.
- Money events are unchanged.
- Decision recorded: is GA4 fed by the backend directly **or** via Singular, never both?

## How the BI agent will verify
`bi-tracking-health` compares the weekly GA4 event count with backend `succeeded` deliveries per event. It closes tqa-007 after two clean weeks.

_Filed by the Manafa BI agent (decision support). Report: `reports/2026/W47/tracking-health-2026-11-16.md`._
