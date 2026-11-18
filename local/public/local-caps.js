/* Local adapter: gives the Command Center page the same three objects claude.ai gives it (window.claude.use),
   backed by the local server. The page file itself is not changed. Chat ("sample") goes through the local
   server to the Claude API when ANTHROPIC_API_KEY is set in local/.env; the page's own tools and guards run here. */
(function () {
  const J = async (url, init) => { const r = await fetch(url, init); let b = null; try { b = await r.json(); } catch (e) {} return { status: r.status, body: b }; };
  const POLL = 4000;

  /* ---- db: collection(...).orderBy().limit().onSnapshot(), doc(path).onSnapshot()/update()/set()/get() ---- */
  const snapDoc = d => ({ id: d.id, exists: true, data: () => { const { id, ...rest } = d; return rest; } });
  function query(col, ops) {
    const run = docs => { let out = docs.slice();
      for (const o of ops) {
        if (o.t === "where") out = out.filter(d => o.op === "==" ? d[o.f] === o.v : o.op === "!=" ? d[o.f] !== o.v : true);
        if (o.t === "orderBy") out.sort((a, b) => { const x = a[o.f], y = b[o.f]; const c = x == null ? (y == null ? 0 : 1) : y == null ? -1 : x < y ? -1 : x > y ? 1 : 0; return o.dir === "desc" ? -c : c; });
        if (o.t === "limit") out = out.slice(0, o.n);
      } return out; };
    const fetchDocs = async () => { const r = await J("/api/db/" + col); if (r.status !== 200) throw { code: "unavailable" }; return run(r.body.docs || []); };
    return {
      where: (f, op, v) => query(col, ops.concat({ t: "where", f, op, v })),
      orderBy: (f, dir) => query(col, ops.concat({ t: "orderBy", f, dir: dir || "asc" })),
      limit: n => query(col, ops.concat({ t: "limit", n })),
      get: async () => ({ docs: (await fetchDocs()).map(snapDoc) }),
      onSnapshot(cb, onErr) { let stop = false, last = null, failed = false;
        const tick = async () => { if (stop) return; try { const docs = await fetchDocs(); const sig = JSON.stringify(docs); if (sig !== last) { last = sig; cb({ docs: docs.map(snapDoc), metadata: { fromCache: false } }); } failed = false; } catch (e) { if (!failed && onErr) onErr(e); failed = true; } if (!stop) setTimeout(tick, POLL); };
        tick(); return () => { stop = true; }; },
    };
  }
  function docRef(p) {
    const [col, id] = String(p).split("/"); const url = "/api/db/" + col + "/" + encodeURIComponent(id);
    const write = async (method, mode, data) => { const r = await J(url + "?mode=" + mode, { method, headers: { "content-type": "application/json" }, body: JSON.stringify(data) }); if (r.status !== 200) throw Object.assign(new Error((r.body && r.body.error && r.body.error.message) || "write failed"), { code: (r.body && r.body.error && r.body.error.code) || "error" }); };
    const read = async () => { const r = await J(url); return r.status === 200 ? { exists: true, id, data: () => r.body.data } : { exists: false, id, data: () => undefined }; };
    return { id, get: read, update: d => write("PATCH", "update", d), set: (d, o) => write("PUT", o && o.merge ? "merge" : "set", d), delete: async () => { await J(url, { method: "DELETE" }); },
      onSnapshot(cb, onErr) { let stop = false, last = null; const tick = async () => { if (stop) return; try { const s = await read(); const sig = JSON.stringify(s.exists ? s.data() : null); if (sig !== last) { last = sig; cb(s); } } catch (e) { if (onErr) onErr(e); } if (!stop) setTimeout(tick, POLL); }; tick(); return () => { stop = true; }; } };
  }
  const db = { collection: name => query(name, []), doc: docRef };

  /* ---- mcp: callTool / watchTool with the same connector and tool names ---- */
  async function callTool(server, tool, input) {
    const r = await J("/api/mcp", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ server, tool, input }) });
    if (!r.body) throw Object.assign(new Error("The local server didn't answer. Is `npm start` still running?"), { code: "upstream_error" });
    if (r.body.error) throw Object.assign(new Error(r.body.error.message), { code: r.body.error.code });
    return r.body.result;
  }
  function watchTool(server, tool, input, handler, opts) {
    let stop = false; const every = Math.max(60000, (opts && opts.refetchInterval) || 300000);
    const tick = async () => { if (stop) return; try { const result = await callTool(server, tool, input); if (!stop) handler({ type: "data", result }); } catch (e) { if (!stop) handler({ type: "error", error: { code: e.code || "upstream_error", message: String(e.message || e) } }); } if (!stop) setTimeout(tick, every); };
    tick(); return () => { stop = true; };
  }
  const mcp = { callTool, watchTool };

  /* ---- sample: same call shape the page uses on claude.ai: sample(turns, {signal, tools, onText}) -> {text, truncated} ---- */
  const MAX_ROUNDS = 12;
  async function sample(turns, opts) {
    opts = opts || {}; const tools = opts.tools || []; const signal = opts.signal;
    const defs = tools.map(t => ({ name: t.name, description: t.description, input_schema: t.inputSchema || { type: "object", properties: {} } }));
    const messages = turns.map(t => ({ role: t.role, content: t.content }));
    let lastText = "", allText = "", truncated = false;
    const cancelled = () => Object.assign(new Error("cancelled"), { code: "cancelled", text: lastText || allText });
    for (let round = 0; round < MAX_ROUNDS; round++) {
      if (signal && signal.aborted) throw cancelled();
      let r;
      try { r = await J("/api/chat", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ messages, tools: defs }), signal }); }
      catch (e) { if (signal && signal.aborted) throw cancelled(); throw Object.assign(new Error("The local server didn't answer."), { code: "upstream_error", text: lastText }); }
      if (!r.body) throw Object.assign(new Error("The local server didn't answer."), { code: "upstream_error", text: lastText });
      if (r.body.error) throw Object.assign(new Error(r.body.error.message), { code: r.body.error.code, text: lastText });
      const res = r.body.result; const content = res.content || [];
      if (res.stop_reason === "refusal") throw Object.assign(new Error("refused"), { code: "refused" });
      const text = content.filter(b => b.type === "text").map(b => b.text).join("\n\n").trim();
      if (text) { lastText = text; allText += (allText ? "\n\n" : "") + text; if (opts.onText) opts.onText({ text }); }
      const calls = content.filter(b => b.type === "tool_use");
      if (res.stop_reason === "max_tokens") { truncated = true; break; }
      if (res.stop_reason !== "tool_use" || !calls.length) {
        if (!text && !calls.length && res.stop_reason === "end_turn" && !allText) throw Object.assign(new Error("empty"), { code: "empty_completion" });
        break;
      }
      messages.push({ role: "assistant", content }); // whole content goes back unchanged (thinking blocks included)
      const results = await Promise.all(calls.map(async c => {
        const tool = tools.find(t => t.name === c.name);
        if (!tool) return { type: "tool_result", tool_use_id: c.id, content: "Unknown tool: " + c.name, is_error: true };
        try { const out = await tool.execute(c.input || {}); return { type: "tool_result", tool_use_id: c.id, content: JSON.stringify(out == null ? null : out) }; }
        catch (e) { return { type: "tool_result", tool_use_id: c.id, content: String((e && e.message) || e), is_error: true }; }
      }));
      if (signal && signal.aborted) throw cancelled();
      messages.push({ role: "user", content: results });
      if (round === MAX_ROUNDS - 1) truncated = true;
    }
    return { text: lastText || allText, truncated, modelTierApplied: "complex" };
  }
  let chatReady = null;
  const chatAvailable = () => chatReady || (chatReady = J("/api/health").then(r => !!(r.body && r.body.chat === "on")).catch(() => false));

  /* ---- status: tells you this is the local copy and what is connected. It sits in the page's sidebar slot
     (#env-slot) when the page has one, otherwise as a small floating pill. ---- */
  function pill() {
    const el = document.createElement("div");
    const floating = "position:fixed;left:12px;bottom:12px;z-index:9999;max-width:560px;font:12px/1.45 system-ui,sans-serif;background:var(--surface,#11141d);color:var(--text-2,#b9bed0);border:1px solid var(--line,#222738);border-radius:10px;padding:8px 12px;box-shadow:0 6px 24px rgba(0,0,0,.4)";
    const place = () => { const slot = document.getElementById("env-slot"); if (slot) { if (el.parentNode !== slot) { el.style.cssText = ""; slot.appendChild(el); } } else if (!el.parentNode) { el.style.cssText = floating; document.body.appendChild(el); } };
    place(); new MutationObserver(place).observe(document.body, { childList: true, subtree: true });
    const dot = ok => '<span style="display:inline-block;width:7px;height:7px;border-radius:50%;margin:0 5px 0 0;background:' + (ok === true ? "var(--ok,#2ebd8c)" : ok === null ? "var(--idle,#5d647c)" : "var(--warn,#f0b24a)") + '"></span>';
    const item = (ok, label) => '<span style="display:inline-flex;align-items:center;white-space:nowrap">' + dot(ok) + label + "</span>";
    const tick = async () => {
      const r = await J("/api/health").catch(() => null); const h = r && r.body;
      if (!h) { el.innerHTML = "<b>Local</b> · server not answering. Run <code>npm start</code> in <code>local/</code>."; }
      else {
        el.innerHTML = '<div style="display:flex;flex-wrap:wrap;gap:4px 10px;align-items:center"><b style="font-weight:600;letter-spacing:.06em;text-transform:uppercase;font-size:10.5px;color:var(--muted,#8289a1)">Local</b>'
          + item(h.google === "ok", "Google") + item(h.sheet === "ok", "Sheet") + item(h.jira === "configured" ? true : null, "Jira") + item(h.chat === "on" ? true : null, h.chat === "on" ? "Chat" : "Chat off") + "</div>"
          + (h.google !== "ok" ? '<div style="margin-top:6px;color:var(--warn,#f0b24a)">Google sign-in needed. In a terminal run <code style="user-select:all">gcloud auth application-default login</code>, then reload.</div>' : "")
          + (h.google === "ok" && h.sheet !== "ok" ? '<div style="margin-top:6px;color:var(--warn,#f0b24a)">Singular sheet sign-in needed: <code style="user-select:all">gcloud auth login --enable-gdrive-access</code></div>' : "")
          + (h.jira !== "configured" ? '<div style="margin-top:4px;color:var(--muted,#8289a1)">Jira is off: add JIRA_EMAIL and JIRA_API_TOKEN to local/.env and restart.</div>' : "");
      }
      setTimeout(tick, h && h.google === "ok" ? 300000 : 15000);
    };
    tick();
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", pill); else pill();
  /* Local preview aid: ?theme=dark or ?theme=light forces a theme for this load. */
  try { const t = new URLSearchParams(location.search).get("theme"); if (t === "dark" || t === "light") document.documentElement.setAttribute("data-theme", t); } catch (e) {}

  /* ---- runner: start / stop loop agents on this computer (local only; claude.ai has no such capability) ---- */
  const runCall = async (url, body) => { const r = await J(url, body === undefined ? undefined : { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
    if (!r.body) throw Object.assign(new Error("The local server didn't answer. Is `npm start` still running?"), { code: "upstream_error" });
    if (r.body.error) throw Object.assign(new Error(r.body.error.message || "failed"), { code: r.body.error.code });
    return r.body.result; };
  const runner = { status: () => runCall("/api/run"), start: agents => runCall("/api/run", { agents }), cancel: () => runCall("/api/run/cancel", {}) };

  window.__MBI_LOCAL__ = true;
  window.claude = { use: async name => name === "db" ? db : name === "mcp" ? mcp : name === "sample" ? ((await chatAvailable()) ? sample : null) : name === "runner" ? runner : null };
})();
