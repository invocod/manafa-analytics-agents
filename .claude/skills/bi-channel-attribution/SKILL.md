---
name: bi-channel-attribution
description: "Weekly channel-attribution loop: production backend conversions as the ledger, GA4 first-touch vs last-touch channel mix and Google Ads claims each in their own section, honest allocation only where backend attribution exists. Never sums or blends sources."
---

# Channel-Attribution Loop

Answer "which channels drive registrations, deposits, investments?" without letting any platform grade its own homework. State: `state/bi-channel-attribution.json` + `.log`.

| Part | Spec |
|---|---|
| **Cadence** | Weekly (Monday, after bi-tracking-health; skip if it escalated on attribution or ledger) |
| **Acts when** | Always produces the readout; flags channels where sources disagree in direction or a claim ratio leaves its band |
| **Stop / bail-out** | Never allocate more conversions than the ledger holds. Never turn a platform-vs-backend gap into a credit multiplier. |
| **Output** | Attribution readout (format below) |

## Before every run (all bi-* loops)

1. Read `CLAUDE.md`, `context/metrics.md` and this loop's `state/<loop>.json`.
2. Run `sql/readonly/source_freshness.sql`. Use only complete days: the backend replica's newest day is usually partial, and the trailing 72 hours are never judged. A source older than 8 days is **stale**: report "stale data — <source>", do not advance the cursor, halt if it is a required source.
3. BigQuery only (`databases-472111`, me-central2), read-only (`execute_sql_readonly`). Build numbers from `context/metrics.md` definitions and `sql/readonly/` queries; aggregated output only. `gold`/`silver`/`curated`/`reporting`/`dashboard_views`/`sama_mart` are suspended (tqa-012).
4. Not in BigQuery = **not configured** (Singular, Meta, TikTok, Snapchat, GA4 platform split). Name them under "Not covered"; never estimate them.
5. After the run: write the report to `reports/<yyyy>/W<ww>/`, update state, append one log line (plus `decision:` lines), commit.

## Loop body

1. **Ledger** (`weekly_kpis.sql`): last closed week's registrations, deposits, investments (count; amounts per currency).
2. **Backend attribution** (`backend_events_daily.sql`, `acquisition_*` and `last_*` fields): report coverage first (share of each event carrying a source). While coverage is low (tqa-014), report "attributed share = X%" and **do not** extrapolate the rest.
3. **GA4 section** (own numbers only): sessions and engaged sessions by channel group; first-user (`ga4_user_acquisition_daily`) vs session (`ga4_traffic_daily`) side by side. GA4 conversion counts for doubled events (tqa-007) are not used.
4. **Google Ads section** (own numbers only): spend, clicks, claimed conversions per action; "platform claims N" next to the ledger, never instead of it.
5. **First-touch vs last-touch gap** per channel: the gap is the insight (demand creation vs closing).
6. **Blind spots**: direct + unassigned share and trend; flag, don't guess.
7. **Trend verdicts** ⬆/➡/⬇ only where sources agree in direction; otherwise "disputed".

## Output
```
🧭 Attribution — week <ww>
Ledger (backend): reg X | dep Y | inv Z   (attributed coverage: reg a% / dep b% / inv c%)
Backend-attributed by source: …   (only the attributed share)
GA4: first-touch vs last-touch by channel …
Google Ads: spend S, claimed conv by action …
Disputed: … | Blind spots: direct+unassigned = __%
Recommendation: <with confidence high/med/low> — for human decision
Not covered: Singular, Meta, TikTok, Snapchat
```
