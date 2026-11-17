# [BE] Acquisition attribution is stored on only 14% of web registrations and ~1% of deposits/investments

- Type: Bug · Priority: High · Parent: ISQ-6052
- Dev Assignee: Mohammad Khubaib
- Labels: bi-agent, analytics, attribution, tqa-014
- Tracking: tqa-014
- Status: CREATED as ISQ-6055 (approved by Amir 2026-11-17)

## Problem
`mi_analytics_events.attribution.acquisition_*` is filled on 134 of 942 web registrations (14%) and on 0 app registrations. Deposits and investments carry it only when the profile had it: deposits ~1%, investments ~1.3%.

## Impact
The backend ledger can't credit any channel or campaign for registrations, deposits or investments. All channel and ROI reporting falls back to platform claims (GA4, Google Ads, Singular), which the agent may not use to count conversions.

## Evidence (aggregated)
- 19 Oct – 11 Nov: registration_completed web 134/942 attributed, iOS 0/1,120, Android 0/351. deposit_success 30/2,316 · investment_completed 276/20,857.
- GA4 shows that about 50% of new web users arrive with a non-direct first source (Organic Search 19%, Performance Max 11%, Paid Search 9%, 9–14 Nov). So far more than 14% of web sign-ups should have a source.

## Likely root cause (inferred)
1. Web: the backend only stores UTMs present on the request at the registration step. UTMs on the landing page are lost after the user navigates (no first-touch cookie). **May need a web follow-up for Khalid Shabbir:** persist first-touch UTMs, referrer and gclid in a cookie/localStorage and send them at sign-up.
2. App: nothing is sent (companion [API][App] ticket for Azib).
3. Money events copy attribution from the profile, so (1) and (2) propagate.

## Where to look
- The Laravel code that builds the `attribution` JSON for `registration_completed`: where `acquisition_*` is read and what request fields or cookies it reads.
- The registration API contract for web and app.

## Acceptance criteria
- An agreed registration contract for attribution (source, medium, campaign, gclid/click id, referrer, first-touch timestamp), shared with the app and web.
- Web registrations ≥ 50% attributed and app ≥ 80% (organic counted explicitly) within two weeks of release.
- Deposits and investments carry the profile's acquisition attribution.

## How the BI agent will verify
Weekly coverage per event and platform in `bi-channel-attribution`. Baseline: reg 5.1% · dep 0.4% · inv 1.3% (W46 Mon–Wed).

_Filed by the Manafa BI agent (decision support). Related: tqa-019 (last-touch)._
