# Google Ads conversion-action audit (Manafa)

**Used by:** tracking-QA check 6, bi-paid-media-review (tracking step). **Read-only:** the agent reads exports and recommends. It never edits conversion actions, goals or tags.

Adapted from `conversion-tracking/references/google-ads.md` (Part B) and `discrepancies.md` in coreyhaines31/marketingskills (MIT). Provenance in `context/upstream-skills.md`. Kept: the parts that apply to an app-first investment platform. Dropped: from-zero tag setup, e-commerce refunds, phone calls, EEA consent specifics.

## Why this matters at Manafa now

- Every ad platform optimizes on `registration_completed` (`context/manafa-marketing.md`).
- GA4 very likely counts `registration_completed` and `kyc_completed` twice in the apps (tqa-007).
- So if Google Ads takes registrations from a **GA4 import** and that action is **Primary**, Smart Bidding is learning from doubled app registrations. If it also takes them from **Singular** (app postback) or a web tag, and more than one is Primary, it double-counts again.
- Which of these is true is **unknown** until the conversion-actions export arrives. Unknown is not a failure (see `ads-audit-guardrails.md`). Don't file it as an issue until the export shows it.

## Inputs (export from Google Ads)

1. **Goals → Conversions → Summary**, all actions including Secondary and removed, downloaded as CSV. Needed columns: conversion action, source (Website / App: Firebase or GA4 / App: third-party analytics such as Singular / Import from GA4 / Import from clicks), category, status, action optimization (Primary/Secondary), count (One/Every), click-through window, view-through window, attribution model.
2. **Campaigns report segmented by Conversions → Conversion action**, last 4 closed weeks. This shows which action produced each campaign's conversions.
3. **Campaign goals:** which campaigns use account-default goals and which use custom goals (Campaign settings → Goals). A screenshot is fine.

Aggregate settings only. No user lists, no customer match files.

## The check, in order

| # | Question | Pass | Fail → recommendation (staged for a human) |
|---|---|---|---|
| 1 | One Primary per real-world action? Map every action to one of: registration, KYC, deposit, investment, other. | Exactly one Primary per action (per web or app scope). | Two or more Primary for the same action = double counting in bidding. Recommend demoting all but one to Secondary. |
| 2 | Is any Primary registration or KYC action sourced from GA4 (web import or Firebase/GA4 app)? | No, or tqa-007 has been fixed and confirmed. | GA4's app registrations and KYC are doubled (tqa-007). Recommend Singular (app) or the native web tag as Primary and the GA4 version Secondary until tqa-007 is closed. |
| 3 | Status of every Primary action | "Recording conversions". | **Unverified** = never fired. **Misconfigured** = worked, now stopped (most urgent). **Tag inactive / Inactive** = stopped on a date: ask what deployed that day. **No recent / Awaiting conversions** = check whether campaigns are running before suspecting the tag. |
| 4 | Count setting | Registration and KYC: **One**. Deposit and investment: decide with the business (One = first deposit only, Every = every deposit) and record the choice in `context/manafa-marketing.md`. | Registration counted Every inflates on retries and duplicate fires. |
| 5 | Windows and model | Click window covers the registration → deposit lag (unmeasured; bi-investor-funnel will measure it). | A window shorter than the lag drops real conversions. Flag it, don't guess the lag. |
| 6 | Campaign goals | Each campaign optimizes on the action it is meant to. | A campaign on custom goals that excludes the Primary registration action, or includes an "other" action, gets misreported conversions. |
| 7 | Conversion mix per campaign (from input 2) | Each campaign's conversions come from the expected action. | "Conversions" mixing page-view-style actions with registrations is misleading. Report by action, never as one number. |

Record each check as Pass / Fail / Unknown / Not applicable. Report coverage separately from health.

## Auto-tagging and the click-ID chain (web only)

- Auto-tagging must be ON (Admin → Account settings) for web conversions and any later offline import from the backend. If GA4 shows Google Ads web traffic as organic or direct, suspect it is off (category C1).
- Redirects that drop `gclid` (http→https, www, deep-link routers, link shorteners) remove Google's credit for the whole path. tqa-004 (deep links overwriting `utm_source`) is the same family of problem.
- App campaigns attribute through the app SDK path (Firebase/GA4 or Singular), not `gclid`. iOS adds `gbraid`/`wbraid` and SKAdNetwork, which lag up to 72h.

## Why GA4, Singular and Google Ads never match (expectation-setting)

These are reasons for a gap, not verdicts. Bands are in `CLAUDE.md`. Per the source-separation rule, such comparisons only happen inside tracking-QA and only produce issues.

| Cause | Direction | Notes |
|---|---|---|
| Google Ads dates conversions by click; GA4 and Singular by event | Ads earlier | Recent Ads days fill in later. Never judge the trailing 72h. |
| Attribution scope: Ads credits its own clicks; GA4 splits across channels | GA4 gives paid search less | Part of the normal 10–30%. |
| View-through, engaged-view, cross-device (App and Video campaigns) | Ads higher | Grows with App/Video/PMax share. |
| GA4 import and native tag both Primary | Ads up to 2× | Settings fix (check 1). |
| App double-fire in GA4 (tqa-007) | GA4-sourced actions ~2× in apps | Specific to Manafa today. |
| GA4 → Ads import lag | Ads later by 1–3 days | Another reason for the 72h rule. |
| Time zone (Ads account vs Riyadh day) | Day boundaries shift | Line up time zone before comparing days. |

## Not in scope for the agent

Live tag tests (`?gclid=TEST`, Tag Assistant), GTM edits, enabling enhanced conversions or offline imports. These are recommendations for the tracking owner. An **offline conversion import of backend `deposit_success`** (via gclid or enhanced conversions for leads) is the strongest long-term fix for bidding quality, but it moves customer identifiers. It needs compliance review (PDPL) before anyone designs it.
