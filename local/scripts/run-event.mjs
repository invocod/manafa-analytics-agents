#!/usr/bin/env node
// Reports one run event to the local Command Center. Used by an agent that the local server started.
// The server stamps the time when the event arrives, so an event must be sent at the moment it happens.
//
//   node local/scripts/run-event.mjs <agent-id> agent_start --steps-total 8 --message "Reading state"
//   node local/scripts/run-event.mjs <agent-id> step_start  --step "Pull cohorts" [--status analyzing]
//   node local/scripts/run-event.mjs <agent-id> step_done   --step "Pull cohorts" --message "24 rows" [--output "file or figure"]
//   node local/scripts/run-event.mjs <agent-id> warning|error --message "..."
//   node local/scripts/run-event.mjs <agent-id> agent_done  --result success|failure|escalation --message "summary" [--outputs "a,b"]
//   node local/scripts/run-event.mjs <agent-id> report      --path reports/2026/W47/name.md
//
// Aggregated numbers only in messages; never personal data.
const [agent, kind, ...rest] = process.argv.slice(2);
const KINDS = ["agent_start", "step_start", "step_done", "warning", "error", "agent_done", "report"];
if (!agent || !KINDS.includes(kind)) { console.error("usage: run-event.mjs <agent-id> <" + KINDS.join("|") + "> [--step s] [--message m] [--status s] [--steps-total n] [--result r] [--output o] [--outputs a,b] [--path p]"); process.exit(2); }
const opts = {};
for (let i = 0; i < rest.length; i++) { const k = rest[i]; if (!k.startsWith("--")) { console.error("unexpected argument: " + k); process.exit(2); } opts[k.slice(2).replace(/-/g, "_")] = rest[++i] ?? ""; }
const run = process.env.MBI_RUN_ID, port = process.env.MBI_PORT || "4600";
if (!run) { console.error("MBI_RUN_ID is not set: this run was not started from the local Command Center, so there is nothing to report to."); process.exit(3); }
try {
  const r = await fetch(`http://127.0.0.1:${port}/api/run/event`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ run, agent, kind, ...opts }) });
  const b = await r.json().catch(() => ({}));
  if (!r.ok || b.error) { console.error("not recorded: " + ((b.error && b.error.message) || r.status)); process.exit(1); }
  console.log("recorded " + kind + (opts.step ? " · " + opts.step : "") + " at " + b.ts);
} catch (e) { console.error("local Command Center not reachable on port " + port + ": " + e.message); process.exit(1); }
