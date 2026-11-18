// Manafa BI Command Center — local host (localhost only).
// Serves the SAME page file as the claude.ai artifact (../ui/command-center/index.html) and stands in for the three
// things claude.ai provides: the page database (db), the connectors (mcp: BigQuery, Google Sheets, Jira) and,
// the chat (Claude API with the key in local/.env; compliance confirmation reported by Amir, 2026-11-18).
// Rules kept from CLAUDE.md: read-only BigQuery, me-central2 only, google_analytics + google_ads datasets only,
// no secrets in code, Jira tickets are created only for a draft the user just approved in the page.
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { execFile } from "node:child_process";
import { parseEnv } from "node:util";
import Anthropic from "@anthropic-ai/sdk";
import { fileURLToPath } from "node:url";
import { loadDb, saveDb, seedIfMissing } from "./scripts/store.mjs";
import { startRun, cancelRun, recordEvent, runnerStatus, closeOrphanRuns } from "./scripts/runner.mjs";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, "..");
try { process.loadEnvFile(path.join(HERE, ".env")); } catch { /* no .env yet: Google works, Jira stays off */ }

const PORT = Number(process.env.PORT || 4600);
const HOST = "127.0.0.1"; // never exposed to the network
const PROJECT = process.env.GCP_PROJECT || "databases-472111";
const LOCATION = process.env.BQ_LOCATION || "me-central2";
const MAX_BYTES = String(process.env.BQ_MAX_BYTES || 3_000_000_000);
const JIRA = { site: process.env.JIRA_SITE || "manafaco.atlassian.net", email: process.env.JIRA_EMAIL || "", token: process.env.JIRA_API_TOKEN || "" };
const SINGULAR_SHEET = "1t885guR7b8CdkpxlQN-s0LDC_FOnvye8mmuh0d6mItg";
const PAGE = path.join(REPO, "ui", "command-center", "index.html");
// Chat: the key is read from local/.env itself (never from the shell), so a key exported for another tool can't be used by mistake.
let envFile = {}; try { envFile = parseEnv(fs.readFileSync(path.join(HERE, ".env"), "utf8")); } catch { /* no .env */ }
const CHAT = { key: envFile.ANTHROPIC_API_KEY || "", model: envFile.ANTHROPIC_MODEL || "claude-opus-5-5", maxTokens: 16000 };

class ApiError extends Error { constructor(code, message, status = 200) { super(message); this.code = code; this.status = status; } }

/* ------------------------------------------------------------------ Google sign-in (gcloud, no key files) */
// Two gcloud sign-ins, because Google blocks the Sheets scope on the application-default one:
//   "adc"  = gcloud auth application-default login        -> BigQuery
//   "user" = gcloud auth login --enable-gdrive-access     -> the Singular sheet
const TOKEN_KINDS = {
  adc: { args: ["auth", "application-default", "print-access-token"], hint: "Run: gcloud auth application-default login" },
  user: { args: ["auth", "print-access-token"], hint: "Run: gcloud auth login --enable-gdrive-access" },
};
const tokenCache = {};
function gcloudToken(kind = "adc") {
  const c = tokenCache[kind];
  if (c && Date.now() < c.exp) return Promise.resolve(c.token);
  const k = TOKEN_KINDS[kind];
  return new Promise((resolve, reject) => {
    execFile("gcloud", k.args, { timeout: 20000, shell: process.platform === "win32" }, (err, out, errOut) => {
      const t = String(out || "").trim();
      if (err && err.code === "ENOENT") return reject(new ApiError("needs_reauth", "The gcloud tool is not installed on this computer. Install it (brew install --cask gcloud-cli), then sign in (local/README.md, step 2)."));
      if (err || !t) return reject(new ApiError("needs_reauth", "Google sign-in missing or expired. " + k.hint + " (local/README.md, step 2). " + String(errOut || err && err.message || "").split("\n")[0]));
      tokenCache[kind] = { token: t, exp: Date.now() + 45 * 60 * 1000 };
      resolve(t);
    });
  });
}
async function gfetch(url, init = {}, kind = "adc") {
  const token = await gcloudToken(kind);
  // No x-goog-user-project header: BigQuery bills the project in the URL, and the header needs the extra
  // serviceusage.services.use permission, which a BigQuery read-only account does not have.
  const r = await fetch(url, { ...init, headers: { authorization: "Bearer " + token, "content-type": "application/json", ...(init.headers || {}) } });
  const text = await r.text(); let body; try { body = JSON.parse(text); } catch { body = { raw: text }; }
  if (!r.ok) {
    const msg = (body.error && body.error.message) || text.slice(0, 300);
    if (r.status === 401) { delete tokenCache[kind]; throw new ApiError("needs_reauth", "Google rejected the sign-in: " + msg + " " + TOKEN_KINDS[kind].hint); }
    if (r.status === 403) throw new ApiError("blocked_by_policy", "Google refused access: " + msg);
    throw new ApiError("upstream_error", msg);
  }
  return body;
}

/* ------------------------------------------------------------------ BigQuery (read-only, allow-listed) */
const BQ_ALLOWED = [
  /^databases-472111\.google_analytics\.events_(\*|\d{8})$/,
  /^databases-472111\.google_ads\.p_ads_[A-Za-z]+_3343082801$/,
  /^databases-472111\.(google_analytics|google_ads)\.INFORMATION_SCHEMA\.(COLUMNS|TABLES)$/i,
];
function checkSql(raw) {
  const s = String(raw || "").trim().replace(/;\s*$/, "");
  if (!s) throw new ApiError("bad_request", "Empty query.");
  let t = s.replace(/'(?:\\.|[^'\\])*'/g, "''").replace(/"(?:\\.|[^"\\])*"/g, '""').replace(/--[^\n]*/g, " ").replace(/\/\*[\s\S]*?\*\//g, " ").replace(/`\s*\.\s*`/g, ".");
  if (t.includes(";")) throw new ApiError("blocked_by_policy", "One statement only.");
  if (!/^\s*\(?\s*(WITH|SELECT)\b/i.test(t)) throw new ApiError("blocked_by_policy", "Only SELECT queries are allowed.");
  const tables = []; const outside = t.replace(/`([^`]*)`/g, (m, id) => { if (id.includes(".")) tables.push(id); return " _q_ "; });
  if (/\b(INSERT|UPDATE|DELETE|MERGE|CREATE|DROP|ALTER|TRUNCATE|GRANT|REVOKE|EXPORT|LOAD|CALL|DECLARE|EXECUTE|BEGIN)\b(?!\s*\()/i.test(outside)) throw new ApiError("blocked_by_policy", "Only read-only SELECT queries are allowed.");
  if (!tables.length) throw new ApiError("blocked_by_policy", "The query reads no allowed table.");
  for (const id of tables) if (!BQ_ALLOWED.some(r => r.test(id))) throw new ApiError("blocked_by_policy", "Table not allowed here: " + id + ". The dashboard reads only google_analytics.events_* and google_ads.");
  if (/\b(FROM|JOIN)\s+[A-Za-z_][\w-]*\s*\.\s*[A-Za-z_]/i.test(outside)) throw new ApiError("blocked_by_policy", "Write every table as a full backticked path.");
  return s;
}
const CACHE_DIR = path.join(HERE, "data", "cache");
const BQ_TTL = 10 * 60 * 1000;
const inflight = new Map();
async function runBigQuery(input) {
  const sql = checkSql(input.query);
  const key = crypto.createHash("sha256").update(sql).digest("hex").slice(0, 24);
  const file = path.join(CACHE_DIR, key + ".json");
  try { const st = fs.statSync(file); if (Date.now() - st.mtimeMs < BQ_TTL) return { payload: JSON.parse(fs.readFileSync(file, "utf8")), cache: { storedAt: st.mtimeMs } }; } catch { /* no cache */ }
  if (inflight.has(key)) return inflight.get(key);
  const p = (async () => {
    const base = `https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT}`;
    let res = await gfetch(base + "/queries", { method: "POST", body: JSON.stringify({ query: sql, useLegacySql: false, location: LOCATION, timeoutMs: 60000, maximumBytesBilled: MAX_BYTES, labels: { source: "mbi-command-center-local" } }) });
    let tries = 0;
    while (res.jobComplete === false && tries++ < 20) {
      const j = res.jobReference; res = await gfetch(`${base}/queries/${j.jobId}?location=${j.location || LOCATION}&timeoutMs=20000`);
    }
    if (res.jobComplete === false) throw new ApiError("upstream_error", "The query didn't finish in time.");
    const payload = { schema: res.schema, rows: res.rows || [], totalRows: res.totalRows, jobComplete: true, totalBytesProcessed: res.totalBytesProcessed, location: LOCATION };
    fs.mkdirSync(CACHE_DIR, { recursive: true }); fs.writeFileSync(file, JSON.stringify(payload));
    return { payload, cache: { storedAt: Date.now() } };
  })().finally(() => inflight.delete(key));
  inflight.set(key, p); return p;
}

/* ------------------------------------------------------------------ Google Sheets (Singular sheet only, read-only) */
async function sheetValues(input) {
  if (input.spreadsheetId !== SINGULAR_SHEET) throw new ApiError("blocked_by_policy", "Only the Singular sheet can be read.");
  const range = String(input.range || ""); if (!/^[A-Za-z0-9_ ]+![A-Z]+\d*:[A-Z]+\d*$/.test(range)) throw new ApiError("bad_request", "Bad range.");
  const r = await gfetch(`https://sheets.googleapis.com/v4/spreadsheets/${SINGULAR_SHEET}/values/${encodeURIComponent(range)}`, {}, "user");
  return { payload: { values: r.values || [] }, cache: { storedAt: Date.now() } };
}

/* ------------------------------------------------------------------ Jira (read; create only for an approved draft) */
function jiraOn() { return !!(JIRA.email && JIRA.token); }
async function jfetch(p, init = {}) {
  if (!jiraOn()) throw new ApiError("server_not_connected", "Jira isn't set up locally. Add JIRA_EMAIL and JIRA_API_TOKEN to local/.env (README, step 4).");
  const r = await fetch(`https://${JIRA.site}${p}`, { ...init, headers: { authorization: "Basic " + Buffer.from(JIRA.email + ":" + JIRA.token).toString("base64"), accept: "application/json", "content-type": "application/json" } });
  const text = await r.text(); let body; try { body = JSON.parse(text); } catch { body = { raw: text }; }
  if (r.status === 401 || r.status === 403) throw new ApiError("needs_reauth", "Jira refused the token (" + r.status + ").");
  if (!r.ok) throw new ApiError("upstream_error", "Jira: " + ((body.errorMessages || []).join("; ") || JSON.stringify(body.errors || {}) || text.slice(0, 200)));
  return body;
}
function adfToMd(n, depth = 0) {
  if (!n) return ""; if (typeof n === "string") return n;
  const kids = (n.content || []).map(c => adfToMd(c, depth)).join("");
  switch (n.type) {
    case "doc": return (n.content || []).map(c => adfToMd(c, depth)).join("\n\n").replace(/\n{3,}/g, "\n\n").trim();
    case "paragraph": return kids;
    case "heading": return "#".repeat((n.attrs && n.attrs.level) || 2) + " " + kids;
    case "bulletList": return (n.content || []).map(c => "- " + adfToMd(c, depth + 1).trim()).join("\n");
    case "orderedList": return (n.content || []).map((c, i) => (i + 1) + ". " + adfToMd(c, depth + 1).trim()).join("\n");
    case "listItem": return (n.content || []).map(c => adfToMd(c, depth)).join("\n");
    case "codeBlock": return "```\n" + kids + "\n```";
    case "hardBreak": return "\n";
    case "rule": return "---";
    case "text": { let t = n.text || ""; for (const m of n.marks || []) { if (m.type === "code") t = "`" + t + "`"; else if (m.type === "strong") t = "**" + t + "**"; else if (m.type === "em") t = "_" + t + "_"; } return t; }
    default: return kids;
  }
}
function mdInline(s) {
  const out = []; const re = /(`[^`]+`|\*\*[^*]+\*\*|_[^_]+_)/g; let last = 0, m;
  while ((m = re.exec(s))) { if (m.index > last) out.push({ type: "text", text: s.slice(last, m.index) }); const tok = m[0];
    if (tok[0] === "`") out.push({ type: "text", text: tok.slice(1, -1), marks: [{ type: "code" }] });
    else if (tok[0] === "*") out.push({ type: "text", text: tok.slice(2, -2), marks: [{ type: "strong" }] });
    else out.push({ type: "text", text: tok.slice(1, -1), marks: [{ type: "em" }] });
    last = m.index + tok.length; }
  if (last < s.length) out.push({ type: "text", text: s.slice(last) });
  return out.length ? out : [{ type: "text", text: " " }];
}
function mdToAdf(md) {
  const content = []; let list = null; let para = [];
  const flushP = () => { if (para.length) { content.push({ type: "paragraph", content: mdInline(para.join(" ")) }); para = []; } };
  const flushL = () => { if (list) { content.push(list); list = null; } };
  for (const line of String(md || "").split("\n")) {
    const h = line.match(/^(#{1,6})\s+(.*)$/), b = line.match(/^\s*[-*]\s+(.*)$/), o = line.match(/^\s*\d+\.\s+(.*)$/);
    if (h) { flushP(); flushL(); content.push({ type: "heading", attrs: { level: h[1].length }, content: mdInline(h[2]) }); }
    else if (b || o) { flushP(); const type = b ? "bulletList" : "orderedList"; if (!list || list.type !== type) { flushL(); list = { type, content: [] }; }
      list.content.push({ type: "listItem", content: [{ type: "paragraph", content: mdInline((b || o)[1]) }] }); }
    else if (!line.trim()) { flushP(); flushL(); }
    else { flushL(); para.push(line.trim()); }
  }
  flushP(); flushL();
  return { type: "doc", version: 1, content: content.length ? content : [{ type: "paragraph", content: [{ type: "text", text: " " }] }] };
}
async function jiraSearch(input) {
  const fields = (input.fields || ["summary", "status"]).join(",");
  const q = new URLSearchParams({ jql: String(input.jql || ""), fields, maxResults: String(Math.min(Number(input.maxResults) || 50, 100)) });
  const r = await jfetch("/rest/api/3/search/jql?" + q.toString());
  const issues = (r.issues || []).map(x => { const f = { ...(x.fields || {}) }; if (f.description && typeof f.description === "object") f.description = adfToMd(f.description); return { key: x.key, id: x.id, fields: f }; });
  return { payload: { data: { issues, isLast: r.isLast !== false } }, cache: { storedAt: Date.now() } };
}
const norm = s => String(s || "").toLowerCase().replace(/\s+/g, " ").trim();
async function jiraCreate(input) {
  // Human-approval guard: only a draft the user has just approved in the page (status "creating") can become a ticket.
  const db = loadDb(); const drafts = Object.values(db.jira_drafts || {});
  const d = drafts.find(x => x.status === "creating" && norm(x.summary) === norm(input.summary));
  if (!d) throw new ApiError("blocked_by_policy", "No approved draft matches this ticket. Tickets are created only from a draft approved with the Approve button.");
  if (input.projectKey !== "ISQ") throw new ApiError("blocked_by_policy", "Only project ISQ.");
  const fields = { project: { key: "ISQ" }, issuetype: { name: input.issueType || "Bug" }, summary: String(input.summary), description: mdToAdf(input.description), labels: input.labels || ["bi-agent"], parent: { key: input.parent || "ISQ-6052" }, ...(input.additional_fields || {}) };
  if (input.priority) fields.priority = { name: input.priority };
  const r = await jfetch("/rest/api/3/issue", { method: "POST", body: JSON.stringify({ fields }) });
  return { payload: { data: { key: r.key, id: r.id } } };
}

/* ------------------------------------------------------------------ chat (one Claude API call per round; the page runs the tools) */
// The page's own guards decide what data a tool may return (read-only, allow-listed tables, aggregates only, no identifiers).
// This endpoint only relays the conversation: fixed model, capped output, no content written to disk or to the log.
const chatOn = () => !!CHAT.key;
const anthropic = chatOn() ? new Anthropic({ apiKey: CHAT.key, authToken: null, baseURL: "https://api.anthropic.com" }) : null;
async function chatRound(input) {
  if (!anthropic) throw new ApiError("sampling_disabled", "Chat isn't set up locally. Add ANTHROPIC_API_KEY to local/.env and restart.");
  const messages = Array.isArray(input.messages) ? input.messages : null;
  if (!messages || !messages.length || messages.length > 80) throw new ApiError("bad_request", "Bad chat request.");
  const tools = (Array.isArray(input.tools) ? input.tools : []).slice(0, 12).map(t => ({ name: String(t.name), description: String(t.description || ""), input_schema: t.input_schema || { type: "object", properties: {} } }));
  try {
    const r = await anthropic.beta.messages.create({
      model: CHAT.model, max_tokens: CHAT.maxTokens,
      thinking: { type: "adaptive" },
      cache_control: { type: "ephemeral" },
      betas: ["server-side-fallback-2026-07-01"], fallbacks: "default", // a safety-classifier decline is retried on a fallback model
      messages, ...(tools.length ? { tools } : {}),
    });
    return { content: r.content, stop_reason: r.stop_reason, model: r.model, usage: { input_tokens: r.usage.input_tokens, output_tokens: r.usage.output_tokens, cache_read_input_tokens: r.usage.cache_read_input_tokens } };
  } catch (e) {
    if (e instanceof Anthropic.AuthenticationError || e instanceof Anthropic.PermissionDeniedError) throw new ApiError("sampling_disabled", "Claude API refused the key in local/.env (" + e.status + ").");
    if (e instanceof Anthropic.RateLimitError) throw new ApiError("rate_limited", "Claude API rate limit or usage limit reached.");
    if (e instanceof Anthropic.BadRequestError && /credit balance/i.test(e.message)) throw new ApiError("rate_limited", "The Claude API account for the key in local/.env has no credit. Add credit under Plans & Billing in the Claude Console.");
    if (e instanceof Anthropic.BadRequestError) throw new ApiError(/too long|too large|context/i.test(e.message) ? "prompt_too_large" : "upstream_error", "Claude API rejected the request: " + e.message);
    if (e instanceof Anthropic.APIError) throw new ApiError("upstream_error", "Claude API error " + (e.status || "") + ": " + e.message);
    throw new ApiError("upstream_error", "Couldn't reach the Claude API: " + String(e.message || e));
  }
}

/* ------------------------------------------------------------------ connector router (same names the page uses) */
async function callTool(server, tool, input) {
  if (server === "Google Cloud BigQuery" && tool === "execute_sql_readonly") return runBigQuery(input || {});
  if (server === "Google Sheets" && tool === "get_values") return sheetValues(input || {});
  if (server === "Atlassian MCP" && tool === "searchJiraIssuesUsingJql") return jiraSearch(input || {});
  if (server === "Atlassian MCP" && tool === "createJiraIssue") return jiraCreate(input || {});
  throw new ApiError("not_in_manifest", `Tool not available locally: ${server} / ${tool}`);
}

/* ------------------------------------------------------------------ page (same file as the artifact, libraries served locally) */
const VENDOR = {
  "react.production.min.js": "react/umd/react.production.min.js",
  "react-dom.production.min.js": "react-dom/umd/react-dom.production.min.js",
  "htm.umd.js": "htm/dist/htm.umd.js",
  "chart.umd.min.js": "chart.js/dist/chart.umd.js",
  "lucide.min.js": "lucide/dist/umd/lucide.min.js",
};
function renderPage() {
  let html = fs.readFileSync(PAGE, "utf8");
  html = html.replace(/<script src="https?:\/\/[^"]*\/([^"\/]+\.js)"><\/script>/g, (m, f) => VENDOR[f] ? `<script src="/vendor/${f}"></script>` : m);
  const i = html.indexOf("<script>"); // first inline script = the app; the local adapter must load before it
  if (i < 0) throw new Error("Page layout changed: inline script not found.");
  return html.slice(0, i) + '<script src="/local-caps.js"></script>\n' + html.slice(i);
}

/* ------------------------------------------------------------------ http */
const send = (res, status, body, type = "application/json") => { const b = typeof body === "string" || Buffer.isBuffer(body) ? body : JSON.stringify(body); res.writeHead(status, { "content-type": type + (type.startsWith("text/") || type.includes("json") || type.includes("javascript") ? "; charset=utf-8" : ""), "cache-control": "no-store", "x-content-type-options": "nosniff" }); res.end(b); };
const readBody = req => new Promise((resolve, reject) => { let s = ""; req.on("data", c => { s += c; if (s.length > 2_000_000) { reject(new ApiError("bad_request", "Body too large", 413)); req.destroy(); } }); req.on("end", () => { try { resolve(s ? JSON.parse(s) : {}); } catch { reject(new ApiError("bad_request", "Invalid JSON", 400)); } }); });
const ID = /^[A-Za-z0-9_.-]{1,80}$/;

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url, `http://${req.headers.host || "localhost"}`);
    // Local only: refuse other hosts and cross-site writes.
    const host = String(req.headers.host || "").split(":")[0];
    if (!["localhost", "127.0.0.1"].includes(host)) return send(res, 403, { error: "localhost only" });
    if (req.method !== "GET") { const o = req.headers.origin; if (o && !/^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(o)) return send(res, 403, { error: "cross-site request refused" }); }
    const p = url.pathname;

    if (req.method === "GET" && (p === "/" || p === "/index.html")) return send(res, 200, renderPage(), "text/html");
    if (req.method === "GET" && p === "/local-caps.js") return send(res, 200, fs.readFileSync(path.join(HERE, "public", "local-caps.js")), "text/javascript");
    if (req.method === "GET" && p.startsWith("/vendor/")) { const f = VENDOR[p.slice(8)]; if (!f) return send(res, 404, { error: "not found" }); const fp = path.join(HERE, "node_modules", f); if (!fs.existsSync(fp)) return send(res, 500, "console.error('Run npm install in local/ first');", "text/javascript"); return send(res, 200, fs.readFileSync(fp), "text/javascript"); }

    if (req.method === "GET" && p === "/api/health") {
      let google = "ok", gmsg = ""; try { await gcloudToken("adc"); } catch (e) { google = "needs_sign_in"; gmsg = e.message; }
      let sheet = "ok"; try { await gcloudToken("user"); } catch (e) { sheet = "needs_sign_in"; gmsg = gmsg || e.message; }
      const db = loadDb();
      return send(res, 200, { ok: true, google, sheet, google_message: gmsg, jira: jiraOn() ? "configured" : "off", chat: chatOn() ? "on" : "off", chat_model: chatOn() ? CHAT.model : null, project: PROJECT, location: LOCATION, page: path.relative(REPO, PAGE), collections: Object.fromEntries(Object.entries(db).map(([k, v]) => [k, Object.keys(v).length])) });
    }

    const m = p.match(/^\/api\/db\/([A-Za-z0-9_]+)(?:\/([^/]+))?$/);
    if (m) {
      const [, col, idRaw] = m; const id = idRaw ? decodeURIComponent(idRaw) : null; if (id && !ID.test(id)) return send(res, 400, { error: "bad id" });
      const db = loadDb(); const c = db[col] || (db[col] = {});
      if (req.method === "GET" && !id) return send(res, 200, { docs: Object.entries(c).map(([k, v]) => ({ id: k, ...v })) });
      if (req.method === "GET") return send(res, c[id] ? 200 : 404, c[id] ? { exists: true, id, data: c[id] } : { exists: false });
      if (!id) return send(res, 400, { error: "id required" });
      if (req.method === "DELETE") { delete c[id]; saveDb(db); return send(res, 200, { ok: true }); }
      const body = await readBody(req); const mode = url.searchParams.get("mode") || (req.method === "PUT" ? "set" : "merge");
      if (mode === "update" && !c[id]) return send(res, 404, { error: { code: "not_found", message: "Document does not exist." } });
      c[id] = mode === "set" ? body : { ...(c[id] || {}), ...body };
      for (const k of Object.keys(c[id])) if (c[id][k] && typeof c[id][k] === "object" && c[id][k].__delete__ === true) delete c[id][k];
      saveDb(db); return send(res, 200, { ok: true, id });
    }

    if (req.method === "POST" && p === "/api/mcp") {
      const b = await readBody(req);
      try { return send(res, 200, { result: await callTool(b.server, b.tool, b.input) }); }
      catch (e) { const code = e.code && typeof e.code === "string" ? e.code : "upstream_error"; console.error(`[${new Date().toISOString()}] ${b.server}/${b.tool}: ${code}: ${e.message}`); return send(res, 200, { error: { code, message: String(e.message || e) } }); }
    }
    if (req.method === "POST" && p === "/api/chat") {
      const b = await readBody(req);
      try { return send(res, 200, { result: await chatRound(b) }); }
      catch (e) { const code = e.code && typeof e.code === "string" ? e.code : "upstream_error"; console.error(`[${new Date().toISOString()}] chat: ${code}: ${e.message}`); return send(res, 200, { error: { code, message: String(e.message || e) } }); }
    }
    // Run agents from the page: one background Claude Code session at a time (scripts/runner.mjs).
    if (p === "/api/run" || p === "/api/run/cancel" || p === "/api/run/event") {
      try {
        if (req.method === "GET" && p === "/api/run") return send(res, 200, { result: await runnerStatus() });
        if (req.method !== "POST") return send(res, 405, { error: "method not allowed" });
        const b = await readBody(req);
        // Starting and stopping come only from the page itself (a browser always sends Origin on POST); events come from the agent's script.
        if (p !== "/api/run/event" && !req.headers.origin) return send(res, 403, { error: { code: "blocked_by_policy", message: "Runs are started from the Command Center page." } });
        if (p === "/api/run") return send(res, 200, { result: await startRun(b.agents) });
        if (p === "/api/run/cancel") return send(res, 200, { result: cancelRun() });
        return send(res, 200, recordEvent(b));
      } catch (e) { const code = typeof e.code === "string" ? e.code : "server_error"; if (code === "server_error") console.error(`[${new Date().toISOString()}] run: ${e.message}`); return send(res, p === "/api/run/event" ? 400 : 200, { error: { code, message: String(e.message || e) } }); }
    }
    return send(res, 404, { error: "not found" });
  } catch (e) { send(res, e.status && e.status >= 400 ? e.status : 500, { error: { code: e.code || "server_error", message: String(e.message || e) } }); }
});

seedIfMissing();
closeOrphanRuns();
server.listen(PORT, HOST, () => {
  console.log(`\nManafa BI Command Center (local)  →  http://localhost:${PORT}\n  page file : ${path.relative(REPO, PAGE)} (same file as the claude.ai artifact)\n  BigQuery  : ${PROJECT} / ${LOCATION}, read-only, google_analytics + google_ads only\n  Jira      : ${jiraOn() ? "configured (" + JIRA.email + ")" : "off (add JIRA_EMAIL + JIRA_API_TOKEN to local/.env)"}\n  Chat      : ${chatOn() ? "on (" + CHAT.model + ")" : "off (add ANTHROPIC_API_KEY to local/.env)"}\n  Status    : http://localhost:${PORT}/api/health\n`);
  runnerStatus().then(r => console.log(`  Run agents: ${r.available ? "on (" + r.cli + "), tools in run-permissions.json" : "off (claude command not found)"}\n`));
});
