/* Local adapter: gives the Command Center page the same three objects claude.ai gives it (window.claude.use),
   backed by the local server. The page file itself is not changed. Chat ("sample") is off locally. */
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

  /* ---- small status pill: tells you this is the local copy and what still needs setting up ---- */
  function pill() {
    const el = document.createElement("div");
    el.style.cssText = "position:fixed;left:12px;bottom:12px;z-index:9999;max-width:560px;font:12px/1.45 system-ui,sans-serif;background:#0d1326;color:#c9d1ea;border:1px solid #2a3558;border-radius:10px;padding:8px 12px;box-shadow:0 6px 24px rgba(0,0,0,.4)";
    document.body.appendChild(el);
    const dot = ok => '<span style="display:inline-block;width:8px;height:8px;border-radius:50%;margin:0 5px 0 10px;background:' + (ok === true ? "#22c38e" : ok === null ? "#8b93b0" : "#f2b136") + '"></span>';
    const tick = async () => {
      const r = await J("/api/health").catch(() => null); const h = r && r.body;
      if (!h) { el.innerHTML = "<b>LOCAL</b> · server not answering. Run <code>npm start</code> in <code>local/</code>."; }
      else {
        el.innerHTML = "<b>LOCAL</b>" + dot(h.google === "ok") + "Google" + dot(h.jira === "configured" ? true : null) + "Jira" + dot(null) + "Chat off"
          + (h.google !== "ok" ? '<div style="margin-top:6px;color:#f2b136">Google sign-in needed. In a terminal run:<br><code style="user-select:all">gcloud auth application-default login --scopes=https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/spreadsheets.readonly</code><br>then reload. (Messages on the page that mention claude.ai connectors mean this, locally.)</div>' : "")
          + (h.jira !== "configured" ? '<div style="margin-top:4px;color:#8b93b0">Jira is off: add JIRA_EMAIL and JIRA_API_TOKEN to local/.env and restart.</div>' : "");
      }
      setTimeout(tick, h && h.google === "ok" ? 300000 : 15000);
    };
    tick();
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", pill); else pill();

  window.__MBI_LOCAL__ = true;
  window.claude = { use: async name => name === "db" ? db : name === "mcp" ? mcp : null };
})();
