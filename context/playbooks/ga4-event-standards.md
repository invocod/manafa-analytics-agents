# GA4 event and key-event standards (Manafa)

**Used by:** tracking-QA (check 7 and the naming audit), the GA4 section of reports. The agent audits GA4 against this standard and recommends; the owning team changes GA4, Laravel, Flutter or Nuxt.

## The authority: Manafa GA4 Event Standard v2.1

The source of truth is Manafa's own **GA4 Event Standard** (file `Manafa_GA4_Event_Standard_v2.1.html`, dated 2026-10-27, page header "v2.0"). It is aligned to the Analytics Implementation Handbook v1.1. A machine-readable copy of its event table is in **`context/ga4-event-standard-v2.1.csv`** (111 rows: name, owner, applies-to, status, key event, parameters, legacy names it replaces). Where this playbook and the standard disagree, the standard wins. Proposed changes to it go to its owner, not into this file.

The essentials loops rely on:

- **One property, three streams** (web, iOS, Android), one vocabulary across Backend (Laravel), Mobile (Flutter) and Web (Nuxt).
- **Ownership (P1–P5):** clients fire *intent* (`*_started`, `*_view`, `*_submitted`); **Laravel fires confirmed truth** (`*_completed`, `*_success`, `*_verified`, failures, reversals). A confirmed-outcome event fired by a client is a **P5 violation**. The standard lists 7 to move to Laravel: `login_completed`, `registration_completed`, `identity_verified`, `investment_completed`, `bank_account_added`, `deposit_success`, `withdrawal_completed`.
- **Names:** snake_case with the handbook's suffix grammar (§8.2): `deposit_success`, not `deposit_completed`. Legacy names are listed per event in `replaces_app` / `replaces_web` and must stop firing after the rename.
- **Removed names:** the "X · Remove" rows (QA_* events, `User_launches_the_app`, redundant `*_Screen_View` events, `gtm.js`, …) must not fire in production.
- **Parameter blocks** (§9 Core, Marketing, Revenue; §7 Attribution, Lifecycle). Money events carry `amount`, `currency` and GA4's reserved `value`, so revenue reports and value-based bidding work.

## Key events (per the standard)

The standard marks **10 key events**: `registration_completed`, `login_completed`, `identity_verified`, `kyc_completed`, `deposit_success`, `investment_completed`, `auto_invest_enabled`, `wallet_created`, `lead_form_completed`, `lead_converted`.

What that means for reporting (the agent's rules):
- **"Key events" in GA4 is not a funnel count.** It includes logins and B2B lead events. Loops always report each funnel event by name, never the key-events total.
- **Counting method** (once per session vs every event) changes the key-event total. Check it in Admin before comparing totals.
- **Google Ads:** a key event becoming an Ads conversion is a separate decision. Recommendation to the owner: `login_completed` should never be a Primary bidding conversion (it is a returning-user action, and very likely doubled today, tqa-007). See `google-ads-conversion-audit.md`.

## Plausibility rules the agent checks

- **A completion can't exceed its start.** In GA4 Oct 20 – Nov 10, `kyc_completed` (2,960) exceeds `kyc_started` (1,744) and `withdrawal_completed` (6,795) exceeds `withdrawal_started` (3,703). That is the tqa-007 signature.
- **A P5 event must be fired by exactly one party.** If Laravel now fires it, the client must have stopped. Both firing doubles it in the stream where the client still fires.
- **Every live event name is in the standard**, either as a current name or a listed legacy name. Anything else is drift and is filed for the standard's owner.

## Parameters and PDPL

- Register a custom dimension only for a parameter someone will segment by. GA4 does not backfill, so register before the first event lands.
- IDs in parameters (`wallet_id`, `investment_id`, `opportunity_id`) are acceptable in GA4. No report, export or state file produced by this agent lists individual IDs.
- **Never** names, emails, phone numbers, national IDs, IBANs or transaction references in any parameter, page title or URL. tqa-005 (long numeric IDs in page titles) is this rule.

## Data-quality settings to verify (Admin)

Internal and developer traffic filtered; staging excluded; cross-domain covers every Manafa web domain; Google Ads link active with auto-tagging on.

## Where to check (no API yet)

- Key events and counting method: Admin → Data display → Key events.
- Custom definitions: Admin → Data display → Custom definitions.
- Event × stream × platform: Explore Recipe B (`context/ga4-explore-recipes.md`).
- Parameter completeness: Recipe D.

Generic guidance in this file was adapted from `analytics/references/ga4-implementation.md` and `event-library.md` in coreyhaines31/marketingskills (MIT); see `context/upstream-skills.md`.
