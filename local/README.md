# Manafa BI Command Center — local (localhost)

Runs the Command Center on your own computer at **http://localhost:4600**.

- It serves the **same page file** as the claude.ai artifact (`ui/command-center/index.html`). Nothing in that file is changed, so the claude.ai Command Center keeps working exactly as before.
- This folder replaces what claude.ai provides: page data (`data/db.json`), BigQuery + Singular sheet (your Google sign-in), Jira (your API token). The chat ("Ask the data") uses the Claude API with your own key (compliance confirmation reported by Amir on 18 Nov 2026).
- Localhost only (bound to 127.0.0.1). BigQuery is read-only, `me-central2`, and limited to `google_analytics` and `google_ads`, enforced in `server.mjs`.

## Setup (you run these; nothing here needs a password typed into a file except the Jira token)

**1. Install** (once)
```
cd local
npm install
```

**2. Sign in to Google** (once; each command opens your browser)

Needs the `gcloud` tool: `brew install --cask gcloud-cli`.
```
gcloud auth application-default login
gcloud auth login --enable-gdrive-access
```
The first sign-in is for BigQuery, the second for the Singular sheet (Google blocks the Sheets permission on the first one). Use the Google account that can read BigQuery project `databases-472111` and open the Singular sheet. No quota-project step is needed.

**3. Start and check**
```
npm start          # leave running; open http://localhost:4600
npm run check      # in a second terminal: tests Google, BigQuery, the sheet and Jira
```

**4. Jira (optional)** — copy `.env.example` to `.env`, set `JIRA_EMAIL` and `JIRA_API_TOKEN` (create the token at id.atlassian.com → Security → API tokens), restart. A ticket is created only when you press **Approve** on a draft; the server refuses any other create.

**5. Chat (optional)** — add `ANTHROPIC_API_KEY=...` to `.env` (create the key in the Claude Console; the account needs credit under Plans & Billing) and restart. Optional: `ANTHROPIC_MODEL` (default `claude-opus-5-5`). Each question is sent to the Claude API together with the results of the queries it runs. The page's own guards still apply before anything is sent: read-only, `google_analytics` + `google_ads` + Singular sheet + Jira only, aggregates only, no identifiers. The server keeps no copy of questions or answers; the chat history stays in your browser.

**6. Run agents from the page** — needs Claude Code installed and signed in on this computer (run `claude` once in a terminal; the same sign-in that has the BigQuery, Google Sheets and Jira connectors). No key in `.env` is used for this.

- **Agents page:** each agent card has a **Run** button. **Run Automation** (top right) starts several agents, one after the other.
- The server starts one background Claude Code session in the repo folder (`claude -p`), one run at a time. Each step shows on the page within about 4 seconds of the agent reporting it. **Stop run** ends it.
- Nobody approves prompts during such a run, so the session may use only the tools in `run-permissions.json`: read files, BigQuery read-only, the Singular sheet, Jira search, write under `state/`, `reports/` and `jira/drafts/`, and commit those. Everything else is refused and shows as a warning on the run: no Slack message, no `git push`, no Jira ticket, no change outside those folders.
- The full session log of each run is kept in `data/run-logs/<run-id>.jsonl` (git-ignored). A run stops by itself after 60 minutes (`timeout_minutes`).
- Runs started here are recorded in the local page data only (trigger "interface"), not in the claude.ai Command Center.

## Good to know
- The pill at the bottom-left shows what is connected. Page messages that mention "claude.ai Settings → Connectors" mean "sign in to Google / set up Jira" here.
- Local page data starts from a snapshot: agents and issues (claude.ai Command Center, 18 Nov 2026), Jira drafts and reports (read from this repo). **Run history starts empty.** `npm run seed` rebuilds it and overwrites local changes.
- Local data and the claude.ai Command Center are **separate**. An Approve pressed here is recorded here only (the Jira ticket itself is real in both).
- BigQuery results are cached for 10 minutes in `data/cache/`; each query is capped at 3 GB scanned (`BQ_MAX_BYTES`).
- `.env`, `data/db.json`, `data/cache/` and `data/run-logs/` are git-ignored.
- Not for production as is: no login, single user, JSON-file storage. See the production notes in the project chat.
