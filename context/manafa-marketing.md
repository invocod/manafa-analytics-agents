# Manafa — Marketing Context

> Every loop reads this file. Keep numbers current — stale targets make loops alert on the wrong things. (Filled 2026-11-11 with Amir; remaining open items are marked.)

## Product

Manafa is a Saudi CMA-regulated investment platform. Users register, complete KYC, fund a wallet, and invest in offerings (debt/equity crowdfunding). Two audiences: **investors** (the marketing funnel below) and **issuers/companies** (B2B, out of scope for these loops).

## The funnel (backend events = truth)

| Stage | Event / metric | Source of truth |
|---|---|---|
| Visit | sessions by channel | GA4 |
| Install (app) | installs by source | Singular |
| Signup | `registration_completed` | Backend (Laravel) |
| KYC / account opened | `kyc_completed` | Backend |
| Wallet funded | `deposit_success` | Backend |
| Invested | `investment_completed` | Backend |

> **Interim (until BigQuery):** "Backend" rows are read from the GA4 key-event export — the events are server-fired from Laravel into GA4, making it the closest available proxy. BigQuery integration restores direct backend truth. Active sources today: GA4, Singular, Google Ads (CSV drops — see `data-sources.md`).

- Primary conversion for ad platforms: **registration** — all platforms currently optimize on `registration_completed`.
- Typical lag between registration and first deposit/investment: **unmeasured**. The funnel-health loop's first run computes the actual p75 lag from historical cohorts and proposes the observation window; until then it uses a conservative 30 days and labels in-window cohorts *pending*.

## Channels & platforms

| Channel | Platform | Notes |
|---|---|---|
| Paid search | Google Ads | |
| Paid social | Meta, TikTok, Snapchat | **No data feed yet** (not configured in loops). Snapchat traffic historically lands in GA4 "Unassigned" — custom channel group rule required (see `utm-convention.md`) |
| Influencers / creators | various | `utm_medium=creator`; own GA4 channel |
| MMP | Singular | app install + in-app attribution |
| Web analytics | GA4 | |
| CRM / lifecycle | None — in-house, messaged from the backend | |

## Weekly targets & thresholds (loops alert against these)

**No formal targets yet.** Loops baseline on **trailing 8-week medians** (same-weekday for daily checks): a metric alerts on deviation from its own baseline, not on missing a plan. Likewise **no hard spend cap** — the ads-check loop alerts on spend *pacing* anomalies vs trailing weeks instead of a fixed cap. When targets or caps are set, put them in this table and the loops will use them:

| Metric | Weekly target | Hard floor / cap |
|---|---|---|
| Registrations | — (baseline) | |
| Deposits | — (baseline) | |
| Investments | — (baseline) | |
| Blended CAC (per registration) | — (baseline) | |
| Weekly ad spend | — (pacing vs trailing weeks) | no hard cap set |

## Known causes calendar

Before alerting on an anomaly, check against: Ramadan / Eid periods, Saudi National Day & Founding Day, salary days (~25th–28th), offering launches/closings (demand is offering-driven!), major deploys, campaign launches. Offering-driven spikes are the **expected shape** of Manafa's traffic — an investment spike during a popular offering is not an anomaly.

No offerings-calendar source is wired up yet (deliberately skipped for now): loops **note** "possibly offering-driven" as a candidate cause without verifying it, and never suppress an alert on that guess alone.

## Learnings

Promoted lessons that should shape future work (added only on human approval; backed by a finished test or a pattern seen in 2+ runs):

| Date | Learning | Evidence | Status |
|---|---|---|---|
| | | | |
