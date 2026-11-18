# Command Center: live run events (protocol every loop follows)

**Page:** Manafa BI Command Center — https://claude.ai/artifact/BxUmXzapbW6xFkoUW5zMPM
**Artifact slug (for db tools):** `58ba680f-6e6f-4aee-92fd-f7bbecec3ce8`
**Page source:** `ui/command-center/index.html` (republish with the artifact tools after edits).

The page shows only what loops write here. **Never write a status, step, percentage or message that didn't happen.** Numbers in messages are aggregated only; never PII.

## Store layout
| Path | Written by | Content |
|---|---|---|
| `agents/<loop-id>` | Claude, when a skill changes | label, description, cadence, acts_when, depends_on, steps, inputs, outputs |
| `runs/<run-id>` | the running loop | one document per run: `started_at`, `ended_at`, `status`, `trigger`, `summary`, `agents{}`, `events[]` |
| `issues/<tqa-id>` | bi-tracking-health | severity, status, owner, title, what, latest, next_check |
| `reports/<id>` | the loop that wrote the report | title, loop, week, run_id, verdict, path, findings (data), insights + actions (AI-generated), markdown |
| `jira_drafts/<draft_id>` | bi-tracking-health (and Claude on approval) | summary, area, priority, issuetype, dev, labels, tqa, status (`staged` → `created`), jira_key, parent, created, description (markdown). See `docs/jira.md`. |

`run-id` = `run-YYYYMMDD-HHMM` (UTC start). One run may hold several loops (e.g. the Monday sequence).

## Statuses (use exactly these)
`queued` (named in the run, not started) · `initializing` (reading CLAUDE.md, state, freshness gate) · `processing` (running queries) · `analyzing` (computing, comparing, diagnosing) · `waiting` (a dependency loop hasn't finished) · `completed` · `failed` · `cancelled`. `idle` is never written; it's the page's default.

## What to write, and when
1. **Run start**: `set runs/<run-id>` with `status:"running"`, `trigger:"chat"`, `era:"bigquery"`, `imported:false`, every loop in `agents` as `{status:"queued"}`, and `events:[{ts, agent:null, kind:"run_start", message}]`.
2. **Loop start**: in `agents.<loop>` set `status:"initializing"`, `started_at`, `steps_total` = number of steps in the skill's loop body (+ freshness gate + write-up), `steps_done:0`, `current_step`. Event `agent_start`.
3. **Each step**: before it, event `step_start` (`step` = step name) and `current_step`, status `processing` or `analyzing`; after it, event `step_done` with a one-line real result in `message` (and `output` if it produced a figure or file), then increment `steps_done`, `tasks_done`, `tasks_pending`.
4. **Problems**: event `warning` (stale source, check not covered) or `error` (query failed, loop halted). A halted loop gets `status:"failed"`.
5. **Loop end**: `status:"completed"`, `ended_at`, `result` (`success` | `failure` | `escalation`), `summary`, `outputs` (file paths). Event `agent_done`.
6. **Run end**: run `status` (`completed` if every loop completed, else `failed`), `ended_at`, `summary`; event `run_done`. Write `reports/<id>` for each report and update `issues/*` that changed.

Write at step boundaries only (the page polls live, so every write appears within seconds). Each write is a `db_write` `merge` on `runs/<run-id>` with the latest `ifVersion`; `events` is an array, so send the whole updated array. Keep `events` under ~400 items per run.

If the Command Center can't be written (tool missing, refusal), run the loop anyway and note "command center not updated" in the run log. The repo stays the system of record.

## Ask the data (chat) — added 2026-11-17

A chat view (`#ask`) where Amir asks questions in plain words. Claude answers on the viewer's own account through the page's `sample` capability (declared 17 Nov, approved by Amir) and can reach data only through four read-only page tools:

| Tool | Reads | Guard (enforced in the page, before the call) |
|---|---|---|
| `run_bigquery` | BigQuery `databases-472111` (me-central2) via `execute_sql_readonly` | SELECT only, one statement; tables limited to `manafa_financing.mi_analytics_events` / `mi_analytics_event_deliveries`, `google_analytics.events_*` / `events_YYYYMMDD` (raw GA4 export; aggregates only, `_TABLE_SUFFIX` filter required, no `user_properties` / user, device, click or transaction IDs; the retired `GA4.p_ga4_*` transfer is blocked), `google_ads.p_ads_{Campaign,CampaignStats,CampaignConversionStats}_3343082801`, google_analytics/google_ads `INFORMATION_SCHEMA.COLUMNS`; gold/silver/curated/reporting/dashboard_views/sama_mart/stg/test/poc blocked; no whole payload/context/attribution JSON, no device or click identifiers; backend queries must aggregate; results with ID-like columns, event timestamps, >1,000 backend rows, or values shaped like mobiles / national IDs / IBANs / emails are withheld |
| `singular_summary` | Singular sheet (`mbi_summary`, or Sheet1 for campaigns, header-checked) | Aggregated in the page, always split by currency |
| `search_jira` | Jira JQL, read-only, max 50 | — |
| `read_command_center` | This page's issues / reports / runs | — |

Every answer shows its sources: each query's SQL / range / JQL, row count, duration, bytes scanned and a result preview. The instructions sent with each question carry the CLAUDE.md rules (backend = conversion truth, no blending sources, 72-hour window, ISO weeks in Riyadh time, Observed vs Inferred, aggregates only) and the open tracking issues. The chat history is kept in the viewer's own browser only. Answers are decision-support.
