# Manafa — Marketing Context

> Fill the `TODO` items once; every loop reads this file. Keep numbers current — stale targets make loops alert on the wrong things.

## Product

Manafa is a Saudi CMA-regulated investment platform. Users register, complete KYC, fund a wallet, and invest in offerings (debt/equity crowdfunding). Two audiences: **investors** (the marketing funnel below) and **issuers/companies** (B2B, out of scope for these loops).

## The funnel (backend events = truth)

| Stage | Event / metric | Source of truth |
|---|---|---|
| Visit | sessions by channel | GA4 |
| Install (app) | installs by source | Singular |
| Signup | `registration_completed` | Backend (Laravel) |
| KYC / account opened | TODO: event name | Backend |
| Wallet funded | `deposit_success` | Backend |
| Invested | `investment_completed` | Backend |

- Primary conversion for ad platforms: TODO — confirm which event is optimized on (registration vs deposit vs investment) per platform.
- Typical lag between registration and first investment: TODO (needed for matched observation windows — cohorts still inside this window are *pending*, not failed).

## Channels & platforms

| Channel | Platform | Notes |
|---|---|---|
| Paid search | Google Ads | |
| Paid social | Meta, TikTok, Snapchat | Snapchat traffic historically lands in GA4 "Unassigned" — custom channel group rule required (see `utm-convention.md`) |
| Influencers / creators | various | `utm_medium=creator`; own GA4 channel |
| MMP | Singular | app install + in-app attribution |
| Web analytics | GA4 | |
| CRM / lifecycle | TODO | |

## Weekly targets & thresholds (loops alert against these)

| Metric | Weekly target | Hard floor / cap | TODO |
|---|---|---|---|
| Registrations | TODO | | |
| Deposits | TODO | | |
| Investments | TODO | | |
| Blended CAC (per registration) | TODO | | |
| Weekly ad spend cap | TODO | halt + alert if breached | |

## Known causes calendar

Before alerting on an anomaly, check against: Ramadan / Eid periods, Saudi National Day & Founding Day, salary days (~25th–28th), offering launches/closings (demand is offering-driven!), major deploys, campaign launches. Offering-driven spikes are the **expected shape** of Manafa's traffic — an investment spike during a popular offering is not an anomaly.

TODO: link or list the current offerings calendar source.

## Learnings

Promoted lessons that should shape future work (added only on human approval; backed by a finished test or a pattern seen in 2+ runs):

| Date | Learning | Evidence | Status |
|---|---|---|---|
| | | | |
