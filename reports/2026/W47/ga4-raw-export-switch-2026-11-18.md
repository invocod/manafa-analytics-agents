# GA4 source switch: raw export (`google_analytics`) — 2026-11-18

**Verdict:** every GA4 figure in the Command Center, the readonly SQL and the loop state now comes from the raw GA4 BigQuery export `databases-472111.google_analytics.events_*` (production copy, streams iOS 6313772845, Android 6314084012, Web 6314227817). The old transfer dataset `GA4.p_ga4_*_413046941` is retired. Google Ads and Singular figures were not touched.

This is an addendum to the W46 tracking-health and channel-attribution reports of 18 Nov: their GA4 numbers came from the transfer and are superseded below.

## What changed in the numbers (GA4 only, W46 = sessions started 9–15 Nov, Riyadh)

| Figure | Old transfer | Raw export | Basis |
|---|---|---|---|
| Sessions | 40,753 | **24,615** | Observed |
| Direct share of sessions | 45.1% | **72.1%** (17,743) | Observed |
| Unassigned share of sessions | 40.5% | **5.4%** (1,326) | Observed |
| Web sessions that are Direct | n/a (no platform split) | **31.2%** (1,251 of 4,014) | Observed |
| New users (first touch), unique | 5,514 | **8,174** | Observed |
| First-touch mix | Direct 50% / Organic 19% / Cross-network 11% / Paid Search 9% | Direct 50.5% / Organic 16.3% / Unassigned 11.9% / Cross-network 7.4% / Paid Search 6.7% | Observed |
| App screen views with a real screen name | ~1% | **iOS 84.1%, Android 78.3%** | Observed |

Cross-checks: weekly session total equals the sum of the channel rows (24,615) and the sum of the daily rows for 9–15 Nov. New users: 8,174 unique vs 8,180 user-days (6 users first seen on two days).

## Issues

- **tqa-001** re-scoped: Unassigned is small; the open question is why app sessions carry no campaign source.
- **tqa-002** paid social 48 sessions in W46.
- **tqa-004** 46 sessions with internal deep-link names as utm_source.
- **tqa-005** 74 page views with long record IDs in path/title. Digits in query strings are ad-platform IDs, not personal data.
- **tqa-007** confirmed on the raw export: double counting unchanged (1.4–2.3×; money events ~1.0).
- **tqa-015** 231 developer/preview sessions (202 localhost ports).
- **tqa-021** premise corrected: most app screens are named; only 18,127 iOS and 9,739 Android views are generic. **ISQ-6084 was filed on the transfer's wrong figure.** A correction comment is drafted and waits for Amir's approval.
- **tqa-024 (new, high, compliance):** the app user property `name` is set for 6,934 iOS and 2,496 Android users (807 / 436 distinct values, letters only, average 4.5–4.7 characters). The pattern fits first names (Inferred; the values were not read). Jira draft d-tqa-024 staged for approval; compliance review recommended.

## Missing data / caveats

- The export holds 1–17 Nov, and 1–3 Nov are near-empty (10, 44, 100 sessions). GA4 baselines start on 4 Nov.
- All tables were created at once on 18 Nov 11:45 UTC. Whether the dataset refreshes daily is **not confirmed**; the freshness gate will show it as stale after 20 Nov if not.
- Age, gender and interests are not in the export; the Users tab shows country, region, city and language instead.

_Decision support by the Manafa BI agent. Aggregates only; no user-level data read or reported._
