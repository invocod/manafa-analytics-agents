# [BE] Events completed by callbacks/jobs reach GA4 without a client_id (identity_verified 90%, KYC 87%)

- Type: Bug · Priority: High · Parent: ISQ-6052
- Dev Assignee: Mohammad Khubaib
- Labels: bi-agent, analytics, ga4, tqa-013
- Tracking: tqa-013
- Status: CREATED as ISQ-6056 (approved by Amir 2026-11-17)

## Problem
For web users, many backend events are delivered to GA4 marked `degraded` with reason `no_ga_client_id`. They can't be joined to the user's GA4 session, so they never show up in GA4 funnels.

## Impact
On web, GA4 misses most identity-verification, KYC, auto-invest and failed-deposit events, and a third of investments. Web onboarding funnels in GA4 understate KYC by ~85–90%.

## Evidence (aggregated, web, 2–11 Nov)
| Event | GA4 deliveries | no client_id |
|---|---|---|
| auto_invest_enabled | 730 | 94% |
| identity_verified | 2,517 | 90% |
| deposit_failed | 49 | 90% |
| kyc_completed | 1,014 | 87% |
| deposit_success | 67 | 52% |
| registration_completed | 370 | 42% |
| investment_completed | 599 | 34% |
| login_completed | 1,062 | **6%** |
| phone_verified | 415 | **8%** |
| email_verified | 117 | **8%** |

- Events triggered **directly by a browser request** (login, phone and email verification) almost always have the client_id. Events finished **later, by a callback, webhook or queued job** (Nafath/identity callback, KYC result, payment-gateway webhook, scheduled auto-invest) mostly don't.
- Not a recent break: excluding investments, the web share is steady at 59–68% every week since 5 Oct. The rise from 44% to 64% in the week of 26 Oct is a mix effect from auto-invest investments leaving the web bucket (see the investment_completed ticket).

## Likely root cause (inferred)
The GA4 sender takes the client_id (from the `_ga` cookie or a header) from the **current HTTP request**. Callbacks, webhooks and queue workers have no browser request, so there's no client_id.

## Suggested fix
- Save the user's latest GA4 `client_id` (and `session_id`) on the profile whenever an authenticated web request carries it, with a timestamp.
- When an event is emitted outside a browser request, use the stored values. Only mark `no_ga_client_id` when none was ever seen.
- Same pattern for the Singular web identifier (Singular web deliveries for identity_verified show the same gap).
- Web check (Khalid Shabbir): confirm every authenticated API call sends the client_id. Today's 6–8% gap on synchronous events is probably consent/ad-block, which is acceptable.

## Acceptance criteria
- `no_ga_client_id` share on web for identity_verified, kyc_completed and auto_invest_enabled below 15% for a full week.

## How the BI agent will verify
`event_delivery_health_daily.sql` weekly by event and platform (`bi-tracking-health`).

_Filed by the Manafa BI agent (decision support)._
