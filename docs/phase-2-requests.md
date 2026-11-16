# Phase 2: data requests and issue owners (prepared 2026-11-16)

Phase 2 can't be done with read-only access. Each item below is a request to the team that owns it. Everything stays in **me-central2 (Saudi Arabia)**.
Amir sends these; the agent re-checks each one in the next bi-tracking-health run after it lands.

## A. Urgent: fix before trusting any warehouse report
| # | Ask | Owner | Why | How we'll verify |
|---|---|---|---|---|
| A1 | **tqa-012:** confirm and fix the source of the `gold`/`silver`/`curated` build. It appears to read **staging** since ~19 Oct. Tell report owners (Looker Studio, `reporting`, `dashboard_views`, `sama_mart`) which numbers are affected. | Data engineering (+ compliance if SAMA reporting reads these layers) | gold week of 2 Nov = 161 investments / 238k SAR = staging exactly; production = 4,717 / 17.4M SAR | `gold.fact_investment` weekly matches `manafa_financing` investment events within ±2% |

## B. Warehouse data (needs BigQuery admin / GA4 admin)
| # | Ask | Owner | Why |
|---|---|---|---|
| B1 | **GA4 raw export** (property 413046941) to dataset `analytics_413046941` in **me-central2**, daily + streaming if affordable | GA4 admin + GCP admin | Production-only reporting (exclude QA streams), web/app split, parameter audit, confirm tqa-001/007 |
| B2 | **Backfill** GA4 Data Transfer and Google Ads Data Transfer to **2026-09-20** (GA4) and 8+ weeks (Ads) | GCP admin | Bands and trends need ≥ 8 weeks; today 9–10 days |
| B3 | **Singular → BigQuery** export (aggregated reporting + attribution) into me-central2 | Analytics + GCP admin | App attribution by network/campaign is "not configured" without it |
| B4 | **Meta, TikTok, Snapchat, X spend** into BigQuery (Data Transfer where supported, else a scheduled loader) in me-central2 | Paid media + GCP admin | CAC/ROI for 4 of 5 paid channels |
| B5 | Fix the **backend replica lag** (now ~3–4 days, last day partial) or publish its schedule | Data engineering | Weekly loops can't cover the full last week |

## C. Tracking fixes (owners act; the agent re-checks)
| Issue | Ask | Owner | Settling check |
|---|---|---|---|
| tqa-007 | Find the 2nd sender of 7 events into GA4 (backend sends once). First check **Singular → Partner configuration → Google Analytics 4 → event mapping** | Analytics | GA4 ÷ backend-sent ≈ 1.0 for login, registration, kyc, withdrawal_completed, passcode_enabled, bank_account_added |
| tqa-013 | Restore GA client_id handoff from web to backend (degraded 44% → 64% from week of 26 Oct); check deploys around 26 Oct | Web frontend + backend | web degraded share back below 45%, trending to < 10% |
| tqa-014 | Populate `attribution.acquisition_*` on backend events (today ~5% of registrations, ~1% of deposits) | Backend | coverage > 80% on registration, deposit, investment |
| tqa-016 | Review Google Ads conversion goals: GA4-imported Android `kyc_completed` (doubled) appears to bid; no registration action exists | Paid media | Conversions → Summary shows intended Primary actions only |
| tqa-015 | Enable GA4 internal/developer traffic filter; dev and preview builds must not use the production measurement ID | Web | no `127.0.0.1`, `netlify.app`, `tagassistant` referrers |
| tqa-003/004 | Apply `context/utm-convention.md` (lowercase, `cpc` for paid, no deep-link names in utm_source) | Marketing + web | violations < 1% of sessions |
| fx-01 | Decide on the web KYC handoff fix (web kyc_14d 28–37% vs app 81–92%, production cohorts) | Product | web kyc_14d ≥ 50% for 2 closed cohorts, app ≥ 85% |

## D. When access exists (Deploy phase)
`marketing_mart` + `marketing-bi-agent` service account (`sql/marketing_mart/README.md`), GitHub remote, scheduled routines, `#marketing-loops` Slack channel.
