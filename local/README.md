# Manafa BI Command Center — local (localhost)

Runs the Command Center on your own computer at **http://localhost:4600**.

- It serves the **same page file** as the claude.ai artifact (`ui/command-center/index.html`). Nothing in that file is changed, so the claude.ai Command Center keeps working exactly as before.
- This folder replaces what claude.ai provides: page data (`data/db.json`), BigQuery + Singular sheet (your Google sign-in), Jira (your API token). The chat is **off** until compliance confirms.
- Localhost only (bound to 127.0.0.1). BigQuery is read-only, `me-central2`, and limited to `google_analytics` and `google_ads`, enforced in `server.mjs`.

## Setup (you run these; nothing here needs a password typed into a file except the Jira token)

**1. Install** (once)
```
cd local
npm install
```

**2. Sign in to Google** (once; opens your browser)
```
gcloud auth application-default login --scopes=https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/spreadsheets.readonly
gcloud auth application-default set-quota-project databases-472111
```
Use the Google account that can read BigQuery project `databases-472111` and open the Singular sheet.

**3. Start and check**
```
npm start          # leave running; open http://localhost:4600
npm run check      # in a second terminal: tests Google, BigQuery, the sheet and Jira
```

**4. Jira (optional)** — copy `.env.example` to `.env`, set `JIRA_EMAIL` and `JIRA_API_TOKEN` (create the token at id.atlassian.com → Security → API tokens), restart. A ticket is created only when you press **Approve** on a draft; the server refuses any other create.

## Good to know
- The pill at the bottom-left shows what is connected. Page messages that mention "claude.ai Settings → Connectors" mean "sign in to Google / set up Jira" here.
- Local page data starts from a snapshot: agents and issues (claude.ai Command Center, 18 Nov 2026), Jira drafts and reports (read from this repo). **Run history starts empty.** `npm run seed` rebuilds it and overwrites local changes.
- Local data and the claude.ai Command Center are **separate**. An Approve pressed here is recorded here only (the Jira ticket itself is real in both).
- BigQuery results are cached for 10 minutes in `data/cache/`; each query is capped at 3 GB scanned (`BQ_MAX_BYTES`).
- `.env`, `data/db.json` and `data/cache/` are git-ignored.
- Not for production as is: no login, single user, JSON-file storage. See the production notes in the project chat.
