# GA4 event and key-event standards (Manafa)

**Used by:** tracking-QA (checks 7 and the naming audit), the GA4 section of reports. The standard the GA4 property is checked against. The agent audits and recommends; the tracking owner changes GA4 and the apps.

Adapted from `analytics/references/ga4-implementation.md` and `event-library.md` in coreyhaines31/marketingskills (MIT), cut down to what applies to Manafa's web + iOS + Android property. Provenance in `context/upstream-skills.md`.

## Naming

- **snake_case, object_action, lowercase:** `registration_completed`, `deposit_success`, `opportunity_view`. GA4 is case-sensitive: `Logged_in` and `logged_in` are two events forever.
- One name per real-world action across web, iOS and Android. A platform difference goes in a parameter (`platform`), never in the name.
- No metric-like names (`prompt_display_rate`): an event records that something happened; rates are computed in reports.
- No trailing underscores, no spelling variants (`wakala_` is the reference spelling).
- Stay well under GA4's 500 distinct event names per property (183 today).
- The legacy Title_Case set (tqa-009) is deprecated. Expected end state: confined to old app versions, then gone. New Title_Case names after Nov 11 are a regression.

## The funnel events (conversion truth until BigQuery = each tool's own count, in its own section)

| Event | Fired from | Expected count rule |
|---|---|---|
| `registration_completed` | Backend (Laravel), on confirmed success | ≤ registration starts; one per user |
| `kyc_completed` | Backend | ≤ `kyc_started`; one per user |
| `deposit_success` | Backend | ≤ `deposit_started` |
| `investment_completed` | Backend | ≤ investment starts |

**Plausibility rule:** a completion can never exceed its start. In GA4 today `kyc_completed` (2,960) exceeds `kyc_started` (1,744) and `withdrawal_completed` (6,795) exceeds `withdrawal_started` (3,703): that is the tqa-007 signature.

## Key events (what GA4 calls conversions)

- **Policy:** mark as key events only the four funnel events above (plus `first_open` / install if the marketing team wants it for app campaigns). Everything else stays a plain event.
- Why: "Key events" columns in GA4 channel reports and anything imported into Google Ads read the key-event set. Today it totals 2.4× the four funnel events (tqa-010), so "key events" in reports is not a funnel count.
- **Counting method:** registration and KYC once per user; deposit and investment every event (or first-only if the business decides; record the choice in `context/manafa-marketing.md`).
- **Google Ads import:** at most one Primary source per real-world action in Google Ads. Until tqa-007 is fixed, GA4-sourced registration and KYC must not be the Primary bidding signal (`google-ads-conversion-audit.md`).

## Parameters

- Money events carry `value` and `currency` (SAR) so revenue-weighted reporting works; Recipe D measures whether they do.
- Register a custom dimension only for a parameter someone will segment by (offering type, platform, step). Each needs scope (event or user) and a parameter name that matches exactly.
- **PDPL:** no names, emails, phone numbers, national IDs, IBANs or transaction references in any event parameter, page title or URL. GA4's `user_id` feature may hold an internal ID, but no report, export or state file produced by this agent ever shows it. tqa-005 (long numeric IDs in page titles) is this rule.

## Data-quality settings to verify (Admin)

- Internal traffic (office IPs, staff test devices) defined and filtered.
- Developer and staging traffic excluded (separate property or data filter).
- Cross-domain measurement covers every Manafa web domain in the journey.
- Session timeout and engaged-session threshold left at defaults unless there's a documented reason.
- Google Ads link active, with auto-tagging on in Google Ads.

## Where to check (no API yet)

- Key events and counting: Admin → Data display → Events (the key-event toggle) and Key events.
- Custom definitions: Admin → Data display → Custom definitions.
- Event × stream × platform counts: Explore Recipe B (`context/ga4-explore-recipes.md`).
- Parameter completeness: Recipe D.
