// `npm run check` (server must be running): confirms each source answers, with one tiny query each.
try { process.loadEnvFile(new URL("../.env", import.meta.url).pathname); } catch {}
const base = "http://localhost:" + (process.env.PORT || 4600);
const call = async (server, tool, input) => { const r = await fetch(base + "/api/mcp", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ server, tool, input }) }); return r.json(); };
const line = (name, r, ok) => console.log((r.error ? "✗ " : "✓ ") + name.padEnd(22) + (r.error ? r.error.code + ": " + r.error.message : ok(r.result.payload)));
const h = await (await fetch(base + "/api/health")).json().catch(() => null);
if (!h) { console.log("✗ Server not running. Start it with: npm start"); process.exit(1); }
console.log("Local data:", JSON.stringify(h.collections));
line("Google sign-in", h.google === "ok" ? { result: { payload: 1 } } : { error: { code: h.google, message: h.google_message } }, () => "signed in");
line("BigQuery · GA4", await call("Google Cloud BigQuery", "execute_sql_readonly", { query: "SELECT MAX(PARSE_DATE('%Y%m%d', _TABLE_SUFFIX)) AS latest FROM `databases-472111.google_analytics.events_*` WHERE REGEXP_CONTAINS(_TABLE_SUFFIX, r'^\\d{8}$')" }), p => "latest day " + (p.rows[0] && p.rows[0].f[0].v));
line("BigQuery · Google Ads", await call("Google Cloud BigQuery", "execute_sql_readonly", { query: "SELECT MAX(segments_date) AS latest FROM `databases-472111.google_ads.p_ads_CampaignStats_3343082801`" }), p => "latest day " + (p.rows[0] && p.rows[0].f[0].v));
line("Blocked table (expect ✗)", await call("Google Cloud BigQuery", "execute_sql_readonly", { query: "SELECT COUNT(*) FROM `databases-472111.manafa_financing.mi_analytics_events`" }), () => "NOT BLOCKED — report this");
line("Singular sheet", await call("Google Sheets", "get_values", { spreadsheetId: "1t885guR7b8CdkpxlQN-s0LDC_FOnvye8mmuh0d6mItg", range: "mbi_summary!L1:M12" }), p => (p.values || []).length + " rows");
line("Jira", await call("Atlassian MCP", "searchJiraIssuesUsingJql", { jql: "key = ISQ-6052", fields: ["summary"], maxResults: 1 }), p => (p.data.issues[0] || {}).key || "no issue");
