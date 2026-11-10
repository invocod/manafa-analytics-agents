# 🔍 Tracking-QA — 2026-11-11 (first run on real data)

**Verdict: ISSUES (5)** · Window: 2026-10-20 → 2026-11-10 (22-day GA4 snapshot; aggregate export — trailing-72h exclusion not possible, noted per check)
Source: `data/exports/ga4/Reports_snapshot.csv` (GA4 property "Manafa Mobile & Web Apps") — **Observed**. Singular, Google Ads: no files yet → receipt checks not covered.

## Coverage

| Check | Status |
|---|---|
| 1. Backend-events heartbeat (daily counts of the 4 ledger events) | **Not covered** — this export has no event-name × date breakdown (see "unblock" below) |
| 2. Platform receipt (GA4 vs Singular vs Google Ads) | **Not covered** — no Singular/Ads files yet |
| 3. UTM audit vs convention | ✅ Ran (82,200 sessions, 799 distinct source/medium) |
| 4. Channel-group check | ◐ Partial — no channel-group section in export; inferred from mediums |
| 5. Diff vs open issues | First data run — 5 new issues filed |

## Findings (prioritized)

### tqa-001 · [high] 79% of sessions are `(direct) / (none)` — acquisition attribution is mostly blind
64,890 of 82,200 sessions (78.9%); first-user scope 73.3%. **Observed.** For an app-heavy product (key events: iOS 31,791 / Android 13,843 / web 12,171) much of this is genuinely app traffic GA4 can't source — but at this share, channel reporting describes a fifth of reality. **Inferred** next-largest contributors: untagged paid social (see tqa-002) and app deep-links. Fix: investigate composition (app vs web split of direct), ensure all paid links carry UTMs, confirm Firebase/app campaign params. Owner: marketing + app eng. Confirming check: direct share by platform (web-only direct share is the honest tell).

### tqa-002 · [high] Paid social is nearly invisible in GA4 — Snapchat 17 sessions, TikTok ~2, Twitter ~58, over 22 days
**Observed.** Either no campaigns ran, or their traffic arrives untagged and lands in `direct` (the known Snapchat in-app-browser issue). If spend ran on these platforms in this window, this is the priority fix: tag every ad with convention UTMs (`snapchat / cpc` etc.). Owner: media buyer. Confirming check: compare with platform spend for the window (needs the Ads/Singular exports).

### tqa-003 · [med] UTM convention violations — case variants and non-convention mediums that never merge back
**Observed**, by sessions: `LinkedIn / Social` 238 · `linkedin / paid_social` 78 · `twitter / paid_social` 53 · `snapchat / paid_social` 17 · `Apple / search` 31 · case-dupes `Twitter / cpc`+`Twitter / CPC` · `Google ads / CPA` · `SnapChat / Content` · `TikTok / CPC` · `SMS / SMSAd`, `Unifonic / SMS`, `SendGrid / Content`. Convention: lowercase, hyphens, medium ∈ {cpc, creator, …}. LinkedIn alone is split across ≥3 spellings. Fix: correct the live links/templates (historical data won't merge); register `linkedin` properly. Owner: whoever builds links (see `context/utm-convention.md`).

### tqa-004 · [med] In-app/internal values polluting utm_source
**Observed:** `send_message_to_scf_borrower / (not set)` 142 · `jbyyfg / (not set)` 146 (gibberish — likely a typo'd live link) · `download_app_modal` 19 · `wallet` 12 · `documents` 11 · `article` 34+58 · `mid_page` 2 · `firebase / dynamic_link` 2. These look like deep-links/dynamic links writing junk into utm_source, which also steals sessions from their true source. Fix: strip or properly name campaign params on internal links; find and fix the `jbyyfg` link. Owner: app eng. Also: `manafacapital.sa` / `manafaco.zoom.us` referrals are self-referral candidates to exclude in GA4 settings.

### tqa-005 · [med] 16–18-digit record IDs in page titles (129 rows)
**Observed** (masked). Shape = internal record/document IDs, not phones or emails; IDs are not personal data under policy — but confirm they aren't payment references, and prefer templated page titles (IDs explode cardinality and can hit GA4 limits). Owner: app eng.

### Positive observations
No `@`/email-shaped values anywhere ✅ · `chatgpt.com / ai-assistant` already arriving (196 sessions) — add the AI-assistants channel rule ✅ convention already specifies it · `sama.gov.sa` referral traffic visible (80 sessions).

## What unblocks the uncovered checks
1. **Heartbeat**: a GA4 export with **event name × date × count** for `registration_completed`, `kyc_completed`, `deposit_success`, `investment_completed` (GA4 → Reports → Engagement → Events, add date, or an Explore). Drop into `data/exports/ga4/`.
2. **Receipt checks**: the Singular CSV (`data/exports/singular/`) and a Google Ads CSV (`data/exports/google-ads/`).

## Slack message (staged — posting starts once #marketing-loops exists)
```
🔍 Tracking-QA — first real run (Oct 20–Nov 10)
Verdict: ISSUES (5)
• [high] 79% of sessions are direct/(none) — attribution mostly blind — investigate composition — mkt+eng
• [high] Paid social nearly invisible (Snap 17, TikTok 2 sessions/22d) — tag ads w/ convention UTMs — media
• [med] UTM case/medium chaos (LinkedIn split 3 ways) — fix live links — link builders
• [med] Deep-links polluting utm_source (incl. gibberish 'jbyyfg', 146 sessions) — app eng
• [med] 16-18-digit IDs in page titles — confirm not payment refs — app eng
Not covered yet: event heartbeat (need event×date export), Singular/Ads receipt checks
```
