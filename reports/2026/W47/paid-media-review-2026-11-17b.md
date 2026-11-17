# Paid media review — W46 (9–15 Nov 2026), re-run with Singular

Run: run-20261117-1003 · 2026-11-17 · bi-paid-media-review
Supersedes nothing: the 06:03 Google Ads calls stand. This run adds the two accounts that only Singular can see (TikTok, X).

**Verdict:** TikTok iOS → **INVESTIGATE** (cost per install up ~80% in 4 weeks at flat spend; clicks up, installs down). X iOS → **INVESTIGATE** (33,550 SAR since 12 Oct, no install reported at all). Google Ads calls unchanged.

Decision-support only. No budget, bid, status or tracking change was made; each call names the person who needs to check it.

## Google Ads (source: BigQuery, google_ads transfer)

| | W46 |
|---|---|
| Spend 9–15 Nov | 7,563 SAR (06:03 run: 7,564; rounding) |

Calls from run-20261117-0603 stand:
- iOS installs — HOLD
- Above 5Mn (B2B) — INVESTIGATE (CRM B2B lead count 9–13 Nov vs 20 claimed)
- Android installs — INVESTIGATE (Primary conversion flags, tqa-016)

Singular's Google Ads figures are not used here. Its Android cost reads 2.2× BigQuery (tqa-018), so Google Ads stays on BigQuery.

## Singular (attribution) — source: Singular sheet, mbi_summary / Sheet1 rows

### TikTok iOS

Settled days only (Mon–Fri of each week; 14–16 Nov are inside the 72-hour window, and iOS SKAN postbacks lag).

| ISO week (Mon–Fri) | Spend SAR | Clicks | Network installs | Singular installs | Click→install (Singular) | Cost per install (Singular) |
|---|---|---|---|---|---|---|
| W43 | 5,396 | 3,535 | 158 | 230 | 6.5% | 23.5 |
| W44 | 5,392 | 2,852 | 204 | 203 | 7.1% | 26.6 |
| W45 | 5,386 | 2,192 | 164 | 153 | 7.0% | 35.2 |
| W46 | 5,392 | 2,916 | 128 | 127 | 4.4% | 42.5 |

Full weeks for context (includes unsettled days in W46): W42 4,845 SAR / 195 installs, W43 7,536 / 335, W44 7,542 / 287, W45 7,536 / 231, W46 7,534 / 190.

- **Observed:** spend is capped at ~1,080 SAR/day and has been flat since 15 Oct.
- **Observed:** cost per install has risen four weeks running (23.5 → 42.5 SAR on settled days).
- **Observed:** TikTok's own install count and Singular's agree on direction (both falling), so this isn't a single-source artifact.
- **Observed:** in W46 clicks rose 33% while installs fell 17%. Click→install dropped from ~7% to 4.4%.
- **Inferred:** the break is after the click. Three candidates, none confirmed:
  1. Creative or audience drawing lower-intent clicks.
  2. An App Store page change.
  3. SKAN postback lag still filling 9–13 Nov.
- **Call: INVESTIGATE.**
  - Owner: TikTok account owner.
  - Check: pull the creative × placement breakdown for 9–13 Nov vs 26–30 Oct.
  - Settles when: if W47's settled days still show click→install under 5%, the cause is post-click (store page or tracking). If it recovers above 6%, it was postback lag.

### X (Twitter) iOS

| ISO week | Spend SAR | Clicks | Cost per click | Installs |
|---|---|---|---|---|
| W42 | 5,550 | 4,359 | 1.27 | not reported |
| W43 | 7,000 | 3,184 | 2.20 | not reported |
| W44 | 7,000 | 3,909 | 1.79 | not reported |
| W45 | 7,000 | 4,230 | 1.65 | not reported |
| W46 | 7,000 | 4,011 | 1.75 | not reported |

- **Observed:** 1,000 SAR/day since 18 Oct (700–800 before). That's 33,550 SAR from 12 Oct to 15 Nov.
- **Observed:** Singular reports no network or attributed installs for X on any day. The outcome of this spend can't be measured from any source we have.
  - Backend attribution can't settle it either: the app sends no attribution at sign-up (tqa-014), and the replica ends 12 Nov.
- **Call: INVESTIGATE.**
  - Owner: X account owner, plus whoever administers Singular.
  - Check: is an X install postback / SKAN mapping configured in Singular for the iOS app?
  - Settles when: installs appear in the sheet for X, or the owner confirms X is run for reach only, with a different success metric.

## Facts vs hypotheses

- **Facts:** all spend, click and install figures above, computed by script from row-level data.
  - Google Ads spend: BigQuery.
  - TikTok and X: Singular sheet rows 12 Oct–15 Nov.
- **Hypotheses:** the three TikTok post-click causes. The X "reach-only" possibility.

## Missing data

- TikTok creative-level and placement data. Not in the Singular export.
- X install attribution. Absent at source.
- Backend registrations after 12 Nov. The replica is stuck, so no backend cross-check is possible.
- Meta and Snapchat. This run doesn't cover them, and there are no exports for them.
