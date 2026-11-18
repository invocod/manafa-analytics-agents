// Local page database: one JSON file (data/db.json), shape { collection: { id: doc } }.
// First start fills it from seed/ (agents, issues: a snapshot of the claude.ai Command Center taken 2026-11-18)
// and from the repo itself (Jira drafts, reports), so nothing personal or secret is involved.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
const HERE = path.dirname(fileURLToPath(import.meta.url));
const LOCAL = path.resolve(HERE, "..");
const REPO = path.resolve(LOCAL, "..");
const FILE = path.join(LOCAL, "data", "db.json");

let cache = null, cacheM = 0;
export function loadDb() {
  try { const m = fs.statSync(FILE).mtimeMs; if (!cache || m !== cacheM) { cache = JSON.parse(fs.readFileSync(FILE, "utf8")); cacheM = m; } } catch { cache = cache || {}; }
  return cache;
}
export function saveDb(db) {
  fs.mkdirSync(path.dirname(FILE), { recursive: true });
  const tmp = FILE + ".tmp"; fs.writeFileSync(tmp, JSON.stringify(db, null, 1)); fs.renameSync(tmp, FILE);
  cache = db; cacheM = fs.statSync(FILE).mtimeMs;
}
const readJson = (f, d) => { try { return JSON.parse(fs.readFileSync(f, "utf8")); } catch { return d; } };

function seedDrafts() {
  const out = {}; const list = readJson(path.join(REPO, "jira", "drafts", "drafts.json"), []);
  for (const d of list) {
    let description = d.description || "";
    try { const md = fs.readFileSync(path.join(REPO, "jira", "drafts", d.draft_id + ".md"), "utf8"); const i = md.indexOf("\n## "); if (i > 0) description = md.slice(i + 1).split("\n## Update ")[0].trim(); } catch { /* keep json text */ }
    out[d.draft_id] = { area: d.area, tqa: d.tqa || [], issuetype: d.issuetype || "Bug", priority: d.priority || "Medium", parent: "ISQ-6052", labels: d.labels || ["bi-agent"], dev: (d.dev && d.dev.name) || null, status: d.status || "staged", jira_key: d.jira_key || null, last_error: null, linked_existing: null, summary: d.summary, description };
  }
  return out;
}
const LOOPS = ["tracking-health", "investor-funnel", "channel-attribution", "paid-media-review", "weekly-exec-digest", "daily-kpi-watch", "campaign-health"];
function seedReports() {
  const out = {}; const root = path.join(REPO, "reports");
  const walk = dir => { for (const e of fs.readdirSync(dir, { withFileTypes: true })) { const fp = path.join(dir, e.name); if (e.isDirectory()) walk(fp); else if (e.name.endsWith(".md")) add(fp); } };
  const add = fp => {
    const markdown = fs.readFileSync(fp, "utf8"); const rel = path.relative(REPO, fp).split(path.sep).join("/");
    const name = path.basename(fp, ".md"); const wk = rel.match(/reports\/(\d{4})\/W(\d{2})\//); const date = (name.match(/\d{4}-\d{2}-\d{2}/) || [])[0];
    const OLD = { "tracking-qa": "tracking-health", "ga4-event-health": "tracking-health", "funnel-health": "investor-funnel", "attribution-readout": "channel-attribution", "analytics-anomaly": "daily-kpi-watch", "weekly-review": "weekly-exec-digest" };
    const loop = LOOPS.find(l => name.startsWith(l)) || OLD[Object.keys(OLD).find(k => name.startsWith(k))]; const title = (markdown.match(/^#\s+(.+)$/m) || [null, name])[1].trim();
    const verdict = (markdown.match(/\*\*Verdict:?\*\*:?\s*([^\n.]{3,60})/i) || markdown.match(/^Verdict:\s*([^\n.]{3,60})/im) || [])[1];
    out[name.replace(/[^A-Za-z0-9_.-]/g, "-")] = { title, week: wk ? `${wk[1]}-W${wk[2]}` : "", loop: loop ? "bi-" + loop : "", created: (date || new Date(fs.statSync(fp).mtimeMs).toISOString().slice(0, 10)) + "T00:00:00Z", verdict: verdict ? verdict.trim() : null, markdown, path: rel };
  };
  try { walk(root); } catch { /* no reports folder */ }
  return out;
}
export function buildSeed() {
  const toMap = arr => Object.fromEntries(arr.map(({ id, ...rest }) => [id, rest]));
  return {
    agents: toMap(readJson(path.join(LOCAL, "seed", "agents.json"), [])),
    issues: toMap(readJson(path.join(LOCAL, "seed", "issues.json"), [])),
    jira_drafts: seedDrafts(),
    reports: seedReports(),
    runs: {},
    meta: { system: { mode: "local", seeded_at: new Date().toISOString(), note: "Seeded from local/seed and the repo. Run history stays in the claude.ai Command Center." } },
  };
}
export function seedIfMissing(force = false) {
  if (!force && fs.existsSync(FILE)) return false;
  const db = buildSeed(); saveDb(db);
  console.log("Seeded local data: " + Object.entries(db).map(([k, v]) => `${k} ${Object.keys(v).length}`).join(", "));
  return true;
}
