# Manafa Marketing Agent

An AI agent that runs Manafa's recurring marketing measurement jobs as **loops** — scheduled Claude cloud routines that clone this repo, run one loop skill each, post findings to Slack, and commit their state back here.

Built from four skills in [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) (`marketing-loops`, `attribution`, `analytics`, `conversion-tracking`), adapted to Manafa: backend events as source of truth, Singular/GA4/ad-platform reconciliation, SAMA/PDPL data rules.

## The loops

| Loop | Cadence | What it does |
|---|---|---|
| [bi-tracking-health](.claude/skills/bi-tracking-health/SKILL.md) | Mon weekly | Events fire, UTMs follow convention, platform counts inside verdict bands |
| [bi-channel-attribution](.claude/skills/bi-channel-attribution/SKILL.md) | Mon weekly | Backend ledger vs Singular/GA4/platform claims; FT vs LT side by side |
| [bi-paid-media-review](.claude/skills/bi-paid-media-review/SKILL.md) | Mon weekly | One HOLD/FIX/TEST/INVESTIGATE call per ad account |
| [bi-weekly-exec-digest](.claude/skills/bi-weekly-exec-digest/SKILL.md) | Mon weekly (last) | The heartbeat digest synthesizing everything |
| [bi-daily-kpi-watch](.claude/skills/bi-daily-kpi-watch/SKILL.md) | daily | Band checks on key metrics; silent when healthy |
| [bi-investor-funnel](.claude/skills/bi-investor-funnel/SKILL.md) | Tue weekly | Signup + activation funnel leaks, one fix proposal |
| [bi-campaign-health](.claude/skills/bi-campaign-health/SKILL.md) | on campaign end | Results vs goals, lessons, reusable assets |

Global rules every loop follows: [CLAUDE.md](CLAUDE.md). Product context and targets: [context/](context/).

## Adoption order (don't enable everything at once)

1. **Step 1 — trust the data**: `bi-tracking-health` + `bi-weekly-exec-digest`. Run 2–3 weeks, fix what QA finds.
2. **Step 2 — attribution + anomaly**: enable `bi-channel-attribution` and `bi-daily-kpi-watch` (anomaly bands need ~8 weeks of history to be quiet; expect noise at first).
3. **Step 3 — action loops**: `bi-investor-funnel`, `bi-paid-media-review`, `bi-campaign-health` on demand.

A loop whose output nobody acts on for weeks is a vanity loop — disable it.

## Setup checklist

- [x] Context docs filled (2026-11-11): KYC event `kyc_completed`, ads optimize on registration, no formal targets (loops baseline on trailing 8-week medians), no hard spend cap (pacing alerts), Slack `#marketing-loops`
- [x] Data sources (updated 2026-11-16): **BigQuery only** (`databases-472111`, me-central2, read-only); CSV drops retired. See `context/data-sources.md` and `context/metrics.md`
- [ ] Create `#marketing-loops` in Slack and invite the team
- [x] BigQuery connected (2026-11-16): `databases-472111`, me-central2 (Saudi) only. Backend ledger + GA4 + Google Ads transfers. Remaining work: backfill the transfers, validate backend counts in tracking-QA, Singular → BigQuery
- [ ] Open items the first runs will settle: reg→deposit lag (bi-investor-funnel measures p75), GA4 custom channel group existence (bi-tracking-health checks)
- [ ] (When scheduling) attach the BigQuery connector (project `databases-472111`) to each routine
- [ ] Attach the **Slack connector** to each routine at claude.ai/code/routines (give it the marketing channel)
- [x] ~~Weekly CSV drops~~ retired 2026-11-16: BigQuery is the only source
- [ ] Singular → BigQuery export (me-central2) so attribution is covered again
- [ ] First run of each loop: dry run — it sets its watermark and baselines, acts on nothing

## Roadmap status

Mode now: **local, on demand, read-only BigQuery** (loops run from the Claude project chat with this folder connected; vetted queries in `sql/readonly/`).

- **Phase 0 (lock down), done 2026-11-16:** raw Singular row-level CSVs deleted (PDPL); read-only query library `sql/readonly/` validated on live data; loop skills renamed `bi-*`.
- **Phase 1 (rebuild on BigQuery), done 2026-11-16:** `context/metrics.md` (one definition per metric; ledger = production `manafa_financing`), production funnel cohorts (`sql/readonly/investor_funnel_cohorts_prod.sql`, 14-day window), `weekly_kpis.sql`, 7 skills rewritten on BigQuery with a shared run-start gate, all loop states re-baselined on production data (CSV-era kept as history), first BigQuery tracking-health run (escalation tqa-012).
- **Phase 2 (data gaps), requests ready, waiting on owners:** `docs/phase-2-requests.md` (tqa-012 gold fix first; raw GA4 export, backfills, Singular + social spend into BigQuery, tracking fixes tqa-007/013/014/015/016).
- **Phase 3 (new loops):** campaign ROI, creator tracking, cohort payback, search-query mining.
- **Deploy (when mature):** GitHub remote, `marketing_mart` dataset + `marketing-bi-agent` service account (`sql/marketing_mart/README.md`), scheduled routines, dashboard on the mart.

## Running a loop manually

Open this repo in Claude Code and ask: *"Run the bi-tracking-health loop for last week"* — the skill, context, and state do the rest. Same body, no automation: perfectly valid while proving a loop out.

## Scheduling (when ready — currently run manually)

Cloud routines need this repo pushed to GitHub first. Then create one routine per loop at claude.ai/code/routines (or ask Claude Code to create them via `/schedule`), with the prompt template below and these crons (Riyadh = UTC+3):

| Loop | Riyadh time | Cron (UTC) | Phase |
|---|---|---|---|
| bi-tracking-health | Mon 07:00 | `0 4 * * 1` | 1 — enable first |
| bi-weekly-exec-digest | Mon 09:00 | `0 6 * * 1` | 1 — enable first |
| bi-channel-attribution | Mon 08:00 | `0 5 * * 1` | 2 — create paused |
| bi-daily-kpi-watch | daily 08:00 | `0 5 * * *` | 2 — create paused |
| bi-paid-media-review | Mon 08:00 | `0 5 * * 1` | 3 — create paused |
| bi-investor-funnel | Tue 08:00 | `0 5 * * 2` | 3 — create paused |

bi-campaign-health has no cron — run it on demand.

## Routine prompt template (what each schedule sends)

```
Read CLAUDE.md fully, then run the <loop-name> loop exactly as .claude/skills/<loop-name>/SKILL.md
specifies, for the last closed period. Read state/<loop-name>.json first; respect its watermark and
dedupe sets. Compute from row-level data. If a data source is unreachable, report it stale and halt —
never fabricate numbers. Write the report to reports/, post the Slack summary to the marketing channel
(skip silently-healthy posts where the skill says so), update state and append the run log, then
commit and push: git add state/ reports/ && git commit -m "loop: <loop-name> <date>" && git push.
Stage recommendations only — never change any ad account, tracking config, or customer-facing surface.
```

## Compliance

SAMA/PDPL rules are baked into `CLAUDE.md`: aggregates only, no PII anywhere, every output is decision-support that a named human approves before it drives spend, customer-facing content, or anything regulatory.
