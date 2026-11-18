// Starts loop agents from the local Command Center: one Claude Code session in the background (claude -p),
// in the repo folder, with only the tools listed in local/run-permissions.json. One run at a time.
// The server writes what it knows itself (run created, session started, session ended); every step event is
// written by the agent through scripts/run-event.mjs and stamped here on arrival. Nothing is estimated.
import fs from "node:fs";
import path from "node:path";
import { spawn, execFile } from "node:child_process";
import { fileURLToPath } from "node:url";
import { loadDb, saveDb, reportDoc } from "./store.mjs";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const LOCAL = path.resolve(HERE, "..");
const REPO = path.resolve(LOCAL, "..");
const LOG_DIR = path.join(LOCAL, "data", "run-logs");
const AGENT_ID = /^bi-[a-z0-9-]{3,40}$/;
const DONE = ["completed", "failed", "cancelled"];
const WORKING = ["initializing", "processing", "analyzing", "running"];

export class RunError extends Error { constructor(code, message) { super(message); this.code = code; } }
const now = () => new Date().toISOString();
const clip = (s, n) => String(s ?? "").replace(/\s+/g, " ").trim().slice(0, n);

function permissions() {
  const p = JSON.parse(fs.readFileSync(path.join(LOCAL, "run-permissions.json"), "utf8"));
  return { allowed: p.allowed || [], denied: p.denied || [], timeoutMs: Math.min(Math.max(Number(p.timeout_minutes) || 60, 5), 180) * 60000 };
}
let cliCheck = null;
function claudeCli() {
  return cliCheck || (cliCheck = new Promise(resolve => execFile("claude", ["--version"], { timeout: 15000 }, (err, out) => resolve(err ? null : String(out).trim()))));
}

let live = null; // { id, child, timer, cancelled, logPath, result }

const labelOf = a => { const x = (loadDb().agents || {})[a]; return (x && (x.label || x.short)) || a; };
function patchRun(id, fn) { const db = loadDb(); const runs = db.runs || (db.runs = {}); const r = runs[id]; if (!r) return null; fn(r); saveDb(db); return r; }
const pushEvent = (r, e) => { r.events = (r.events || []).concat({ ts: now(), ...e }).slice(-400); };

/** Runs left "running" by a server that stopped: say so instead of showing them live forever. */
export function closeOrphanRuns() {
  const db = loadDb(); let n = 0;
  for (const [id, r] of Object.entries(db.runs || {})) {
    if (r.trigger !== "interface" || DONE.includes(r.status)) continue;
    for (const a of Object.values(r.agents || {})) if (!DONE.includes(a.status)) { a.status = a.status === "queued" ? "cancelled" : "failed"; a.ended_at = now(); a.current_step = null; }
    r.status = "failed"; r.ended_at = now(); r.summary = "The local server stopped while this run was in progress.";
    pushEvent(r, { agent: null, kind: "error", message: "Local server restarted: the run's session is gone." }); n++;
  }
  if (n) saveDb(db);
}

export async function runnerStatus() {
  const cli = await claudeCli();
  return { available: !!cli, cli, live: live ? live.id : null, reason: cli ? null : "The claude command was not found. Install Claude Code and sign in (run `claude` once in a terminal)." };
}

function buildPrompt(id, agents) {
  return `You were started from the local Manafa BI Command Center (localhost). Nobody is watching this session, so no permission prompt can be answered.

Run these loops in this order, each by invoking its skill and following it fully: ${agents.join(", then ")}.

Run id: ${id}. The run already exists in the local Command Center. Do not create another run, and do not write this run to the claude.ai Command Center artifact: for this run, the command below replaces the ArtifactData writes described in docs/command-center.md.

Report progress with this command at the moment each thing happens (the server stamps the time on arrival):
  node local/scripts/run-event.mjs <loop-id> agent_start --steps-total <n> --message "<what you are reading>"
  node local/scripts/run-event.mjs <loop-id> step_start --step "<step name>" [--status analyzing]
  node local/scripts/run-event.mjs <loop-id> step_done --step "<step name>" --message "<one-line real result>"
  node local/scripts/run-event.mjs <loop-id> warning --message "<stale source, check not covered, tool refused>"
  node local/scripts/run-event.mjs <loop-id> error --message "<query failed, loop halted>"
  node local/scripts/run-event.mjs <loop-id> report --path reports/<yyyy>/W<ww>/<file>.md
  node local/scripts/run-event.mjs <loop-id> agent_done --result success|failure|escalation --message "<summary>" --outputs "<path,path>"

Write every message in plain language (it is read by managers, not analysts):
- Short sentences and everyday words. Say what happened and what it means; in agent_done also say what happens next and who acts.
- No unexplained jargon or internal codes: no data_end, cohort_age, band, MAD, median, 7d/14d, W44-style week codes, table, SQL or file names. Say "data up to 16 Nov", "people who signed up in the week of 26 Oct", "within two weeks", "higher than usual". An issue or fix id may follow the plain words in brackets, e.g. "(tqa-023)".
- Few numbers, rounded, with a comparison that gives them meaning: "about 15 of every 100 iPhone sign-ups deposited within two weeks, up from about 10 usually".
- Step names are plain too: "Check the data is up to date", "Count sign-ups and next steps", "Compare with recent weeks", "Check tracking problems", "Find the biggest drop-off", "Suggest one fix", "Save results".
- step_done: one sentence, at most about 25 words. agent_done: two or three sentences: the verdict, why, what's next. File paths go only in --output / --outputs.
- The markdown report keeps its full technical detail; plain language applies to these messages.

Rules for reporting:
- Send step_start before you begin a step and step_done right after it finishes, as separate calls. Never batch several events at the end, and never report a step you did not run.
- steps-total = the steps in the skill's loop body, plus the freshness gate, plus the write-up.
- A loop that halts (stale source, BigQuery unreachable) ends with an error event and agent_done --result failure.
- Messages carry aggregated numbers only, never personal data.

Tools that are not allowed are refused automatically (Slack, git push, anything that writes outside state/, reports/ and jira/drafts/). When a step needs one, skip that step, send a warning event that names it, and carry on. Commit state/ and reports/ as the skill says; do not push.

End with a short summary of each loop's verdict, in the same plain language.`;
}

export async function startRun(agentIds) {
  const st = await runnerStatus();
  if (!st.available) throw new RunError("runner_unavailable", st.reason);
  if (live) throw new RunError("run_in_progress", `Run ${live.id} is still in progress. Wait for it or stop it first.`);
  const db = loadDb(); const known = db.agents || {};
  const agents = [...new Set(Array.isArray(agentIds) ? agentIds : [])].filter(a => typeof a === "string" && AGENT_ID.test(a) && known[a] && fs.existsSync(path.join(REPO, ".claude", "skills", a, "SKILL.md")));
  if (!agents.length || agents.length !== (agentIds || []).length) throw new RunError("bad_request", "Pick at least one agent that has a skill in this repo.");
  const perm = permissions();

  const t = new Date(); const pad = n => String(n).padStart(2, "0");
  let id = `run-${t.getUTCFullYear()}${pad(t.getUTCMonth() + 1)}${pad(t.getUTCDate())}-${pad(t.getUTCHours())}${pad(t.getUTCMinutes())}`;
  if ((db.runs || {})[id]) id += pad(t.getUTCSeconds());
  (db.runs || (db.runs = {}))[id] = { started_at: now(), status: "running", trigger: "interface", era: "bigquery", imported: false,
    agents: Object.fromEntries(agents.map(a => [a, { status: "queued" }])),
    events: [{ ts: now(), agent: null, kind: "run_start", message: "You started " + agents.map(labelOf).join(", then ") + " from the Command Center." }] };
  saveDb(db);

  fs.mkdirSync(LOG_DIR, { recursive: true });
  const logPath = path.join(LOG_DIR, id + ".jsonl"); const log = fs.createWriteStream(logPath);
  // The session signs in the way your terminal does (claude.ai login), which is what gives it the BigQuery, Sheets and
  // Jira connectors. Keys from local/.env and this server's own Claude variables must not leak into it.
  const env = Object.fromEntries(Object.entries(process.env).filter(([k]) => !/^(CLAUDE|ANTHROPIC_|JIRA_)/.test(k)));
  env.MBI_RUN_ID = id; env.MBI_PORT = String(process.env.PORT || 4600);
  const args = ["-p", buildPrompt(id, agents), "--output-format", "stream-json", "--verbose", "--allowedTools", ...perm.allowed];
  if (perm.denied.length) args.push("--disallowedTools", ...perm.denied);
  const child = spawn("claude", args, { cwd: REPO, env, stdio: ["ignore", "pipe", "pipe"] });
  const me = live = { id, child, cancelled: false, logPath, result: null, denied: new Set() };
  me.timer = setTimeout(() => { me.timedOut = true; child.kill("SIGTERM"); }, perm.timeoutMs);

  let buf = "";
  child.stdout.on("data", c => { log.write(c); buf += c; let i;
    while ((i = buf.indexOf("\n")) >= 0) { const line = buf.slice(0, i); buf = buf.slice(i + 1); if (!line.trim()) continue;
      try { const m = JSON.parse(line); if (m.type === "result") { me.result = m; for (const d of m.permission_denials || []) me.denied.add(d.tool_name); } } catch { /* not json */ } } });
  let errTail = ""; child.stderr.on("data", c => { log.write(c); errTail = (errTail + c).slice(-600); });
  child.on("error", e => finish(me, null, "Couldn't start Claude Code: " + e.message));
  child.on("close", code => finish(me, code, errTail));
  patchRun(id, r => pushEvent(r, { agent: null, kind: "step_done", step: "Session started", message: "The agent is starting up on this computer." }));
  return { id, agents };
}

function finish(me, code, errText) {
  if (me.finished) return; me.finished = true; clearTimeout(me.timer); if (live === me) live = null;
  const res = me.result; const ok = code === 0 && res && !res.is_error;
  patchRun(me.id, r => {
    const why = me.cancelled ? "You stopped this run." : me.timedOut ? "The run took longer than the time limit and was stopped." : ok ? null : "The agent stopped because of an error, so its results are incomplete." + (errText ? " Error: " + clip(errText, 200) : res && res.result ? " Error: " + clip(res.result, 200) : "");
    for (const [a, s] of Object.entries(r.agents || {})) {
      if (DONE.includes(s.status)) continue;
      if (s.status === "queued") { s.status = "cancelled"; pushEvent(r, { agent: a, kind: "warning", message: "This agent didn't get to run because the run ended first." }); }
      else { s.status = me.cancelled ? "cancelled" : "failed"; s.result = me.cancelled ? undefined : "failure"; pushEvent(r, { agent: a, kind: "error", message: why || "The run ended before this agent said it had finished, so its results may be incomplete." }); }
      s.ended_at = now(); s.current_step = null;
    }
    if (me.denied.size) pushEvent(r, { agent: null, kind: "warning", message: "The agent asked to do some things it isn't allowed to do in runs started from this page, and was stopped each time (tools: " + [...me.denied].slice(0, 12).join(", ") + "). It carried on without them." });
    const states = Object.values(r.agents || {}).map(a => a.status);
    r.status = me.cancelled ? "cancelled" : states.length && states.every(s => s === "completed") ? "completed" : "failed";
    r.ended_at = now();
    const verdicts = Object.entries(r.agents || {}).filter(([, s]) => s.summary).map(([a, s]) => (Object.keys(r.agents).length > 1 ? (labelOf(a) + ": ") : "") + s.summary);
    r.summary = [why, ...verdicts].filter(Boolean).join("\n\n") || (r.status === "completed" ? "All agents finished." : "Not every agent finished.");
    if (res && res.result) r.final_text = String(res.result).slice(0, 12000);
    if (res) r.usage = { duration_ms: res.duration_ms, turns: res.num_turns, cost_usd: res.total_cost_usd };
    pushEvent(r, { agent: null, kind: r.status === "completed" ? "run_done" : "error", message: r.status === "completed" ? "All agents finished." : (why || "The run ended, but not every agent finished.") });
  });
}

export function cancelRun() {
  if (!live) throw new RunError("not_running", "No run is in progress.");
  live.cancelled = true; live.child.kill("SIGTERM");
  const me = live; setTimeout(() => { if (!me.finished) me.child.kill("SIGKILL"); }, 8000);
  return { id: live.id };
}

/** One event from the running agent (scripts/run-event.mjs). Accepted only for the run in progress. */
export function recordEvent(b) {
  if (!live || b.run !== live.id) throw new RunError("not_running", "That run is not in progress here.");
  const agent = String(b.agent || ""), kind = String(b.kind || "");
  const ts = now(); let out = { ts };
  const r = patchRun(live.id, r => {
    const s = r.agents && r.agents[agent]; if (!s) throw new RunError("bad_request", `Agent ${agent} is not part of run ${r.id}. Agents: ${Object.keys(r.agents || {}).join(", ")}`);
    const step = clip(b.step, 120), message = clip(b.message, 600);
    if (kind === "agent_start") { Object.assign(s, { status: "initializing", started_at: ts, steps_total: Math.min(Math.max(parseInt(b.steps_total, 10) || 0, 0), 60) || undefined, steps_done: 0, tasks_done: 0, current_step: message || "Starting" }); if (s.steps_total) s.tasks_pending = s.steps_total; pushEvent(r, { agent, kind, message: message || "Agent started" }); }
    else if (kind === "step_start") { if (!step) throw new RunError("bad_request", "--step is required"); if (!s.started_at) s.started_at = ts; s.status = b.status === "analyzing" ? "analyzing" : "processing"; s.current_step = step; pushEvent(r, { agent, kind, step, message: message || step }); }
    else if (kind === "step_done") { if (!step) throw new RunError("bad_request", "--step is required"); s.steps_done = (s.steps_done || 0) + 1; s.tasks_done = s.steps_done; if (s.steps_total) s.tasks_pending = Math.max(0, s.steps_total - s.steps_done); const e = { agent, kind, step, message: message || step }; if (b.output) e.output = clip(b.output, 300); pushEvent(r, e); }
    else if (kind === "warning" || kind === "error") { if (!message) throw new RunError("bad_request", "--message is required"); pushEvent(r, { agent, kind, message }); }
    else if (kind === "agent_done") { const result = ["success", "failure", "escalation"].includes(b.result) ? b.result : null; if (!result) throw new RunError("bad_request", "--result success|failure|escalation is required");
      Object.assign(s, { status: result === "failure" ? "failed" : "completed", ended_at: ts, result, summary: message, current_step: null }); if (!s.started_at) s.started_at = ts;
      if (b.outputs) s.outputs = String(b.outputs).split(",").map(x => clip(x, 200)).filter(Boolean).slice(0, 20);
      pushEvent(r, { agent, kind, message: message || "Agent finished" }); }
    else if (kind === "report") {
      const fp = path.resolve(REPO, String(b.path || "")); if (!fp.startsWith(path.join(REPO, "reports") + path.sep) || !fp.endsWith(".md") || !fs.existsSync(fp)) throw new RunError("bad_request", "--path must be an existing .md file under reports/");
      const doc = reportDoc(fp); out.report = doc.id; pushEvent(r, { agent, kind: "step_done", step: "Report filed", message: doc.data.title, output: doc.data.path });
      r._report = { id: doc.id, data: { ...doc.data, loop: agent, run_id: r.id, created: ts } };
    }
    else throw new RunError("bad_request", "Unknown event kind: " + kind);
  });
  if (r && r._report) { const db = loadDb(); const rep = db.runs[live.id]._report; delete db.runs[live.id]._report; (db.reports || (db.reports = {}))[rep.id] = rep.data; saveDb(db); }
  return out;
}
