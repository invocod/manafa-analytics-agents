# GA4 Explore recipes

These are the GA4 exports the loops need and the standard Reports screens can't give us. Each recipe is a Free-form exploration. Build it once, save it in GA4, then re-export it whenever a loop asks for it.

**Rules for every recipe:**
- Date range is **Oct 20 – Nov 10, 2026** for the first pull, so it lines up with the existing snapshot and the Singular files. Later pulls cover the last closed week.
- Check the property's reporting time zone under Admin → Property details. It should be Asia/Riyadh. If it isn't, note it in the file name.
- **Aggregates only (PDPL).** Never add User ID, Effective user ID, Client ID or any user-level dimension.
- Look for the sampling badge at the top right of the canvas. A green check means unsampled. A yellow badge means the data is sampled: split the range into weeks and export each week. A shield icon means data thresholds are applied. Say so when you drop the file, and don't change the reporting identity without the GA4 owner.
- To export, use the **Export data** (download) icon at the top right of the canvas, then **CSV**. Drop the file into `data/exports/ga4/` under the name given in each recipe.

---

## Recipe A — Session source/medium × platform (confirms tqa-001)

**Question:** how much of "direct" is app sessions, which GA4 labels direct by design, and how much is genuinely untagged web traffic?

1. **Explore**, then **Blank**. Name the exploration `tqa-001 source-medium x platform`.
2. **Variables** panel:
   - Date range: Custom, Oct 20 – Nov 10, 2026.
   - Dimensions (+): `Platform`, `Session source / medium`.
   - Metrics (+): `Sessions`, `Engaged sessions`, `Key events`.
3. **Settings** panel (Technique: Free form):
   - Rows: `Session source / medium`. Show rows: **500**.
   - Columns: `Platform`.
   - Values: `Sessions`, `Engaged sessions`, `Key events`.
4. Export as `explore-source-medium-x-platform-20261020-20261110.csv`.

The Totals row covers all rows, including those past row 500, so the shares stay exact.

**How the loop reads it:**

| Result | Verdict |
|---|---|
| Web direct ≤ 40% of web sessions, and app direct ≥ ~85% | Confirmed structural. Close tqa-001 and set baseline `web_direct_share`. |
| Web direct > 40% of web sessions | Web tagging gap is real. Re-raise tqa-001 to med and size it by source. |
| Non-direct app rows (deep links, store) | Shows which app entry points carry a source. This feeds tqa-004. |

Expected from the 2026-11-11 investigation: web direct of about 18–38%, and Singular shows 38.5% of web sessions with no source.

---

## Recipe B — Key events × stream × platform (closes tqa-007)

**Question:** GA4 counts more registrations (3,010) and KYC completions (2,960) than Singular (1,894 and 1,546), but deposits match exactly. Where does the excess come from?

1. **Explore**, then **Blank**. Name the exploration `tqa-007 events x stream x platform`.
2. **Variables** panel:
   - Same date range as Recipe A.
   - Dimensions: `Event name`, `Stream name`, `Platform`.
   - Metrics: `Event count`, `Total users`.
3. **Settings** panel:
   - Rows: `Event name`, then `Stream name` (nested).
   - Columns: `Platform`.
   - Values: `Event count`, `Total users`.
   - Filters: `Event name` → matches regex → `^(registration_started|registration_completed|kyc_completed|deposit_success|investment_completed)$`
4. Export as `explore-events-x-stream-x-platform-20261020-20261110.csv`.

**Singular, same window, for comparison:**

| Event | iOS | Android | Web | Total | GA4 total |
|---|---|---|---|---|---|
| registration_completed | 942 | 290 | 662 | 1,894 | 3,010 |
| kyc_completed | 988 | 292 | 266 | 1,546 | 2,960 |
| deposit_success | 1,529 | 311 | 135 | 1,975 | 1,975 |
| investment_completed | 6,847 | 2,588 | 5,319 | 14,754 | 16,002 |

**How the loop reads it:**

| Pattern in the export | Meaning | Action |
|---|---|---|
| One event appears under **two streams** for the same platform (for example the app stream plus a server stream) | Double-firing: Laravel's server-side copy plus a client SDK copy. The ledger overcounts. | **Escalate.** Ledger integrity is at stake, and every downstream loop uses these counts. |
| `Event count` well above `Total users` for registration or KYC | The event fires more than once per user, for example on retry or reload. | Count users, not events, for identity events. Propose a dedup fix. |
| The excess sits in **one platform column** | That platform's tracking (GA4 or the Singular SDK) is off there. | Narrow tqa-007 to that platform. |
| The excess is spread evenly across all platforms, and users ≈ events | A definitional difference, such as Singular counting only SDK-matched users. | Record the ratio as the known baseline and close tqa-007 as normal. |

---

## Recipe C (optional) — Daily key events × platform

This is Recipe B with `Date` as the first row dimension and no `Stream name`. It gives per-platform daily series. That unlocks per-platform anomaly bands (analytics-anomaly) and the 72-hour exclusion at platform level.

Export as `explore-events-daily-x-platform-<start>-<end>.csv`.
