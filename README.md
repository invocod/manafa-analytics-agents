# Manafa Marketing Agent

An AI agent that runs Manafa's recurring marketing measurement jobs as **loops** — scheduled Claude cloud routines that clone this repo, run one loop skill each, post findings to Slack, and commit their state back here.

Built from four skills in [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) (`marketing-loops`, `attribution`, `analytics`, `conversion-tracking`), adapted to Manafa: backend events as source of truth, Singular/GA4/ad-platform reconciliation, SAMA/PDPL data rules.

## The loops

| Loop | Cadence | What it does |
|---|---|---|
| [tracking-qa](.claude/skills/tracking-qa/SKILL.md) | Mon weekly | Events fire, UTMs follow convention, platform counts inside verdict bands |
| [attribution-recon](.claude/skills/attribution-recon/SKILL.md) | Mon weekly | Backend ledger vs Singular/GA4/platform claims; FT vs LT side by side |
| [weekly-ads-check](.claude/skills/weekly-ads-check/SKILL.md) | Mon weekly | One HOLD/FIX/TEST/INVESTIGATE call per ad account |
| [weekly-marketing-review](.claude/skills/weekly-marketing-review/SKILL.md) | Mon weekly (last) | The heartbeat digest synthesizing everything |
| [analytics-anomaly](.claude/skills/analytics-anomaly/SKILL.md) | daily | Band checks on key metrics; silent when healthy |
| [funnel-health](.claude/skills/funnel-health/SKILL.md) | Tue weekly | Signup + activation funnel leaks, one fix proposal |
| [campaign-postmortem](.claude/skills/campaign-postmortem/SKILL.md) | on campaign end | Results vs goals, lessons, reusable assets |

Global rules every loop follows: [CLAUDE.md](CLAUDE.md). Product context and targets: [context/](context/).

## Adoption order (don't enable everything at once)

1. **Phase 1 — trust the data**: `tracking-qa` + `weekly-marketing-review`. Run 2–3 weeks, fix what QA finds.
2. **Phase 2 — attribution + anomaly**: enable `attribution-recon` and `analytics-anomaly` (anomaly bands need ~8 weeks of history to be quiet; expect noise at first).
3. **Phase 3 — action loops**: `funnel-health`, `weekly-ads-check`, `campaign-postmortem` on demand.

A loop whose output nobody acts on for weeks is a vanity loop — disable it.

## Setup checklist

- [x] Context docs filled (2026-11-11): KYC event `kyc_completed`, ads optimize on registration, no formal targets (loops baseline on trailing 8-week medians), no hard spend cap (pacing alerts), Slack `#marketing-loops`
- [x] Data sources set (2026-11-11): **GA4 + Singular + Google Ads via CSV drops** into `data/exports/ga4|singular|google-ads/`; GA4 key events serve as the interim conversion ledger until **BigQuery** integration lands and becomes backend truth
- [ ] Create `#marketing-loops` in Slack and invite the team
- [x] BigQuery connected (2026-11-16): `databases-472111`, me-central2 (Saudi) only. Backend ledger + GA4 + Google Ads transfers. Remaining work: backfill the transfers, validate backend counts in tracking-QA, Singular → BigQuery
- [ ] Open items the first runs will settle: reg→deposit lag (funnel-health measures p75), GA4 custom channel group existence (tracking-qa checks)
- [ ] (When moving to APIs/scheduling) secrets on the Claude cloud environment: `GA4_SERVICE_ACCOUNT_JSON`, `GA4_PROPERTY_ID`, `SINGULAR_API_KEY`, or BigQuery credentials
- [ ] Attach the **Slack connector** to each routine at claude.ai/code/routines (give it the marketing channel)
- [ ] Weekly: drop fresh GA4/Singular/Google Ads CSVs into `data/exports/` and push (see its README)
- [ ] First run of each loop: dry run — it sets its watermark and baselines, acts on nothing

## Running a loop manually

Open this repo in Claude Code and ask: *"Run the tracking-qa loop for last week"* — the skill, context, and state do the rest. Same body, no automation: perfectly valid while proving a loop out.

## Scheduling (when ready — currently run manually)

Cloud routines need this repo pushed to GitHub first. Then create one routine per loop at claude.ai/code/routines (or ask Claude Code to create them via `/schedule`), with the prompt template below and these crons (Riyadh = UTC+3):

| Loop | Riyadh time | Cron (UTC) | Phase |
|---|---|---|---|
| tracking-qa | Mon 07:00 | `0 4 * * 1` | 1 — enable first |
| weekly-marketing-review | Mon 09:00 | `0 6 * * 1` | 1 — enable first |
| attribution-recon | Mon 08:00 | `0 5 * * 1` | 2 — create paused |
| analytics-anomaly | daily 08:00 | `0 5 * * *` | 2 — create paused |
| weekly-ads-check | Mon 08:00 | `0 5 * * 1` | 3 — create paused |
| funnel-health | Tue 08:00 | `0 5 * * 2` | 3 — create paused |

campaign-postmortem has no cron — run it on demand.

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
