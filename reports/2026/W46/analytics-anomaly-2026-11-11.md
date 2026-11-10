# ⚠️→✅ Analytics-Anomaly — 2026-11-11 (first run)

**Verdict: all ledger metrics in band on the latest complete day; one tracking artifact routed to tracking-qa.** No Slack alert warranted (artifact ≠ demand anomaly).

Mode note: data arrives as drops, not daily feeds, so this run checked the latest complete Riyadh day (**Mon 2026-11-09**) and scanned the whole Oct 20–Nov 9 window. Daily cadence activates when exports arrive daily (or via API/BigQuery). Spend: **skipped — no Google Ads export** (never estimated). Bands are provisional: 3 weeks of history, not the 8 the loop wants (only 2 same-weekday priors per metric).

## Latest-day band check (Riyadh days, Singular all platforms — Observed)

| Metric | Mon Nov 9 | Band (median ±3×MAD, 20 prior days) | Same-weekday priors | Verdict |
|---|---|---|---|---|
| registration_completed | 65 | 55 – 118 | 150, 106 | ✅ in band (soft end of Monday range — watch, don't alert) |
| kyc_completed | 61 | 55 – 94 | 83, 67 | ✅ |
| deposit_success | 75 | 20 – 164 | 109, 116 | ✅ |
| investment_completed | 1,024 | 0 – 1,171 | 336, 1,224 | ✅ |
| sessions (Singular __SESSION__) | 3,329 | 1,140 – 6,066 | 3,689, 4,554 | ✅ |

## Window scan — explained movers (logged, not alerted; known causes)
- **Investments Oct 22 = 3,224** (vs median 574) and registrations Oct 22 = 128 → offering-launch shape, Manafa's expected pattern.
- **Registrations Oct 26 = 150, deposits Oct 27 = 236, sessions Oct 27/Nov 1 high** → salary-days window (~25th–28th). Known cause.
- Zero-days: none on any ledger event. ✅

## The artifact: `App Install` started existing on Oct 30

Zero for Oct 20–29 → 7 on Oct 30 → 318 (Nov 2) → 742–963/day (Nov 3–9), across iOS and Android. Registrations flowed normally through the zero period, which rules out "no installs happened." **Read: tracking artifact — install tracking was enabled/fixed around Oct 30–Nov 2** (SDK change, new Singular tracker, or an export-scope change). **Inferred**; the one check that settles it: what changed in the Singular config or app release that week.

**Routed to tracking-qa as tqa-008**: confirm the cause; treat install baselines as starting 2026-11-03; do not compute install trends across the boundary.

## State
Cursor → 2026-11-09. Bands seeded for all five metrics. an-001 (App Install step) recorded as routed, so future runs won't re-flag the same boundary.
