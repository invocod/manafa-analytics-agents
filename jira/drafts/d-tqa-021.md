# [App] GA4 receives no screen names from the Flutter app (99% of screen views are FlutterViewController / MainActivity)

- Type: Bug · Priority: Medium · Parent: ISQ-6052
- Dev Assignee: AzibMuzammil
- Labels: bi-agent, analytics, ga4, tqa-021
- Tracking: tqa-021
- Status: CREATED as ISQ-6084 (approved by Amir 2026-11-18, Command Center button)

## Problem
In GA4, almost every app screen view is reported under the native container class, not the Flutter screen: `FlutterViewController` (iOS) and `MainActivity` (Android).

## Impact
Nobody can see which app screens people use, where they drop off between screens, or how long they spend on each. App behaviour reports in GA4 and the Command Center's Users tab can't break the app down by screen.

## Evidence (aggregated, GA4 Pages & Screens, 10–16 Nov)
- `FlutterViewController` 143,347 views and `MainActivity` 56,552 views: about 99% of app screen views.
- The other app classes are system or SDK screens (PermissionsActivity 2,637, UIAlertController 2,020, Intercom, Help Center).
- The web, by contrast, reports real page paths.

## Likely root cause (inferred)
The Firebase Analytics SDK logs automatic screen views using the native activity / view controller. A single-activity Flutter app has one of each. No `screen_view` with a `screen_name` is logged when Flutter routes change.

## Suggested fix
- Add a `NavigatorObserver` (e.g. `FirebaseAnalyticsObserver`, or a custom observer for go_router / auto_route) that logs `screen_view` with `screen_name` and `screen_class` on every route change.
- Use route names from the event standard (snake_case, stable, no IDs in names).
- Optionally turn off automatic screen reporting so the container class stops polluting reports.

## Acceptance criteria
Generic classes (`FlutterViewController`, `MainActivity`) are below 20% of app screen views for a full week, and the main screens (home, opportunity list/detail, invest, deposit, withdraw, KYC steps) appear by name.

## How the BI agent will verify
Weekly share of app screen views by class in GA4 Pages & Screens (`bi-tracking-health`).

_Filed by the Manafa BI agent (decision support)._

## Update 2026-11-18 — premise corrected
The figure above came from the retired GA4 transfer tables. In the raw GA4 export (9–15 Nov), 84.1% of iOS and 78.3% of Android screen views carry a real screen name; only 18,127 iOS and 9,739 Android views are generic. Correction comment posted on ISQ-6084 with Amir's approval (comment 174594), suggesting the ticket be narrowed or closed.
