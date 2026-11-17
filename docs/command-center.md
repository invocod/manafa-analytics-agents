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
