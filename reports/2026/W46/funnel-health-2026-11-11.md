# 🩺 Funnel Health — 2026-11-11 (first run)

**Worst leak found: web registrants don't complete KYC — 25.8% vs ~90% in the apps.** One fix proposed below.

Method upgrade: Singular logs carry `custom user id` on 100% of registrations, so these are **true user cohorts** (joined across platforms — a web registrant who finishes KYC in the app counts as converted), not period ratios. Cohort = registrants Oct 20 – Nov 2 (everyone has a full 7-day observation window). n = 1,364. All figures **Observed** from row-level data; outputs aggregate-only.

## The lag question — answered (unblocks cohort ROI)

Among registrants who convert: KYC happens in **~2 minutes** (99% same-day). Deposits: p50 = 20 min, 77% same-day, **p90 ≈ 4.7 days**. Investments: p90 ≈ 6.7 days. → **A 7-day cohort window captures ~90% of early conversions** and is now the standard observation window (right-censoring caveat: only 21 days of data; late converters beyond that are invisible yet).
*Context doc update proposed: replace "lag unmeasured / conservative 30d" with the 7-day window.*

## Cohort funnel (registrants with full 7-day window, n=1,364)

| Step (within 7d of registration) | Rate | Weekly stability (W43/44/45 cohorts) |
|---|---|---|
| → kyc_completed | 68.1% | 71% / 68% / 67% — stable, no regression |
| → deposit_success | 8.3% | 6.9% / 9.4% / 7.4% — W44 = salary week |
| → investment_completed | 3.8% | — |

No step regressed vs its (short) baseline — the find is structural, not a regression.

## The leak, segmented

| Registration platform | n | KYC within 7d |
|---|---|---|
| iOS | 680 | **92.8%** |
| Android | 199 | **86.9%** |
| **Web** | **485** | **25.8%** |

Paid/organic barely matters (web paid 37%, web organic 24% — both terrible; app ≥85% both ways). **Facts:** the gap is platform-shaped, not channel-shaped; web registrants are 36% of the cohort; cross-platform completion is already counted. **Hypothesis (Inferred, one product question settles it):** KYC likely requires the app (Nafath/ID verification), so web registrants face a download-and-log-in-again cliff — and ~74% never cross it. **Missing data:** whether a web KYC path exists at all; drop-off inside the KYC screens (no screen-level events on web).

**Size of prize:** web at even 60% (still below app) ≈ **+55 KYC-completed investors/week**; at app parity ≈ +100/week — on a base of ~450 total KYC completions/week, a 12–22% lift from one flow.

## Proposed fix (exactly one — for human approval)

**fx-01: Fix the web registration → KYC handoff.** First confirm with product whether KYC is web-possible. Then either (a) enable web KYC, or (b) make the handoff seamless: immediately after web registration, show a QR/SMS deep link that opens the app **already authenticated** straight into KYC.
**Measurement plan:** metric = weekly-cohort `kyc_7d` for web registrants (baseline 24–37%, n≈160 web reg/week — sample sufficient); window = 4 weekly cohorts post-ship; success = web kyc_7d ≥ 50% sustained for 2 consecutive cohorts; guardrail = app kyc_7d stays ≥ 85%.

## Also noted (not this loop's proposal)
87% of the window's 1,181 unique depositors are pre-existing users — new-registrant deposits (8.3% at 7d) are a small stream into a large pool, consistent with the attribution readout. KYC→deposit (68% → 8.3%) is the next-biggest leak but is partly offering/demand-driven; revisit after fx-01 and with an offerings calendar.
Signup flow (sessions → registration_started → completed): skipped — `registration_started` tracked only since Nov 2 (tqa-008); first comparable week lands next run.

## Pending cohorts excluded
Registrants Nov 3–9 (window still open on deposits/investments; their KYC-only rates shown in weekly table are stable).
