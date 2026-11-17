# [API][App] App sends no acquisition attribution to the backend at registration (0 of 1,471 app sign-ups)

- Type: Bug · Priority: High · Parent: ISQ-6052
- Dev Assignee: AzibMuzammil
- Labels: bi-agent, analytics, attribution, tqa-014
- Tracking: tqa-014
- Status: CREATED as ISQ-6054 (approved by Amir 2026-11-17)

## Problem
No registration made in the iOS or Android app carries acquisition attribution in the backend event (`attribution.acquisition_source/medium/campaign` is empty).

## Impact
The backend is the source of truth for registrations, deposits and investments. Without app attribution, Manafa can't tell which channel or campaign (Google Ads, TikTok, X, Snapchat) produced app investors. Deposits and investments inherit the profile's attribution, so they're blind too. App users are ~60% of registrations.

## Evidence (aggregated, 19 Oct – 11 Nov)
| Platform | registration_completed | with acquisition_source |
|---|---|---|
| iOS | 1,120 | **0** |
| Android | 351 | **0** |
| Web | 942 | 134 (14%) |

Singular attributes app installs to networks (e.g. 1,738 attributed installs 9–14 Nov), so the attribution exists on the device side. It just never reaches the backend.

## Likely root cause (inferred)
The registration API call from the app doesn't include any attribution fields. The app never reads the Singular attribution (or the install referrer / deep-link params) to pass it on.

## Suggested approach
- On first launch, read the Singular attribution callback (SDK `singularLinksHandler` / deferred deep-link data) and the Android Install Referrer. Store source, medium and campaign locally.
- Send them with the registration request in the fields the backend expects (align with Khubaib on the contract in the companion [BE] ticket).
- Organic / unknown installs send an explicit value (e.g. `source=organic`), not nothing, so "no data" and "organic" can be told apart.

## Acceptance criteria
- ≥ 80% of new app registrations carry `attribution.acquisition_source` (organic counted explicitly).
- Values follow `context/utm-convention.md` (lowercase, network names as in Singular).

## How the BI agent will verify
Weekly coverage of `attribution.acquisition_source` on `registration_completed` by platform (`bi-channel-attribution`).

_Filed by the Manafa BI agent (decision support). Report: `reports/2026/W47/channel-attribution-2026-11-17.md`._
