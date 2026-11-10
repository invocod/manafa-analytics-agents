# 🧭 Attribution Readout — 2026-11-11 (first run)

**Window:** Oct 20 – Nov 9, 2026 (~3 weeks; GA4 tables run to Nov 10 — 1-day offset noted). First run: no trend verdicts yet; this readout sets the baseline and the claim-ratio bands.
**Sources:** GA4 snapshot + engagement exports, Singular event logs (web/Android/iOS) — all **Observed**. Google Ads export: **not provided** — the platform's own claims could not be compared this run.
**Ledger caveat:** interim ledger = GA4 key events (per `CLAUDE.md`); money events are verified against Singular (deposits 100%, investments 92% ✅) but **registration/KYC counts are measurement-suspect (tqa-007)** — Singular's counts shown side by side.

## The question
Which channels actually drive registrations, deposits, and investments — and can we trust the numbers enough to shift budget?

## The ledger

| Event | GA4 (interim ledger) | Singular | Status |
|---|---|---|---|
| registration_completed | 3,010 ⚠️ | 1,908 | identity gap under investigation |
| kyc_completed | 2,960 ⚠️ | 1,562 | same |
| deposit_success | 1,975 | 1,976 | ✅ reconciled |
| investment_completed | 16,002 | 14,761 | ✅ reconciled |

## What each source says — registrations by channel (Singular attribution, all platforms)

| Channel | Registrations | Share | → KYC | → completion |
|---|---|---|---|---|
| Organic / unattributed | 1,086 | 57% | 827 | 76% |
| Google Ads | 365 | 19% | 307 | 84% |
| TikTok Ads | 246 | 13% | 245 | **99.6%** |
| Snapchat Ads | 160 | 8% | 158 | **98.8%** |
| AI assistants (chatgpt.com) | 13 | 0.7% | 8 | 62% |
| Other (internal/custom/social) | 38 | 2% | 17 | — |

Paid channels deliver **~40% of attributed registrations** — and TikTok/Snapchat cohorts complete KYC at ~99% (likely because in-app events inherit install attribution, so these are true same-user progressions). **High confidence, directional.**

## Deposits & investments by channel — read with care

| Channel | Deposits | Investments |
|---|---|---|
| Organic / unattributed | 1,775 (90%) | 14,208 (96%) |
| Google Ads | 55 | 220 |
| TikTok Ads | 49 | 28 |
| Snapchat Ads | 35 | 31 |
| Custom/agency campaigns | 61 | 256 |
| Apple Search Ads | 1 | 18 |

**Do not read this as "paid doesn't produce depositors."** Deposits and investments this window come overwhelmingly from the **existing user base**, whose install attribution is long-expired → "organic/unattributed". A user registered via TikTok this window hasn't had time to deposit — the registration→deposit lag is unmeasured (funnel-health's first job). Judging acquisition channels on same-window deposits violates the matched-observation-window rule. **Low confidence by design; cohort analysis needed.**

## GA4 traffic mix (context, session scope)
Direct 79% · Paid search 6.9% · Organic search 6.3% · App stores 4.6% · Referral 1.8% · Internal/junk 0.6% · Social 0.3% · AI assistants 0.25% · Paid social 0.18%.
GA4's paid-social share (0.18% of sessions) vs Singular's paid-social share (21% of attributed registrations) is the clearest demonstration that **GA4 alone cannot be used to judge app acquisition**.

## First-touch vs last-touch
Not properly computable yet: GA4 exports lack key events × channel, and Singular app attribution is install-based (first-touch-like) while its web rows carry last-touch UTMs. The FT-vs-LT conversion comparison becomes possible with a GA4 "key event × first-user channel vs session channel" export — or properly with BigQuery. **Named gap, not estimated.**

## Blind spots
- **Direct = 79% of sessions** and **"organic/unattributed" = 57–96% per conversion event**: the majority of conversions have no channel story. Expected contributors: existing-user traffic, untagged paid-social web clicks (tqa-002/003), app deep-links (tqa-004), dark social, AI assistants (13 registrations already visible — a floor).
- **Platform self-claims unverified**: without the Google Ads export we can't run the over-claim check (platform-claimed vs Singular/GA4-attributed). Google Ads claims would be expected to exceed Singular's 365 — magnitude unknown.

## Recommendation (decision-support — for human decision, not auto-applied)
1. **Keep TikTok + Snapchat live** (high confidence, directional): ~21% of attributed registrations at ~99% KYC completion. They are invisible in GA4 — evaluate them in Singular only.
2. **Hold any budget reallocation between paid channels** until (a) the Google Ads export lands (claims check) and (b) the registration→deposit lag is measured so cohort ROI is computable (medium confidence otherwise).
3. **Add self-reported attribution** ("How did you hear about us?" at registration, pick-list + free text): with 57–96% of conversions unattributed, it's the cheapest tiebreaker available and the standard fix for a dark-social/brand-heavy mix.
4. **Close tqa-007** (GA4 event × platform explore) before anyone quotes GA4's registration counts as the ledger.

## State initialized
Claim-ratio bands (Singular/GA4): deposits 1.00, investments 0.92, registrations 0.63, KYC 0.53 — future runs alert when a ratio leaves ±0.1 of its band, which detects breakage without resolving tqa-007 first.
