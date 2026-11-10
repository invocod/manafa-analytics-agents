# CSV exports drop zone

Loops read the freshest file per source; anything older than 8 days is **stale**, a folder with no file at all is **not configured**.

**Active now (paste your files here):**

```
data/exports/ga4/ga4-2026-11-11.csv            ← GA4 export (the interim ledger)
data/exports/singular/singular-2026-11-11.csv  ← Singular export
data/exports/google-ads/google-ads-2026-11-11.csv
```

Any `.csv` filename works — the date-in-name convention just makes freshness obvious. Keep the header row exactly as the platform exported it; loops adapt to the columns present and report what they couldn't check.

**Not active yet:** `meta/`, `tiktok/`, `snapchat/`, `backend/` (backend truth arrives via BigQuery integration instead — see `context/data-sources.md`).

Once the repo is on GitHub, cloud loops read from there: `git add data/exports && git commit -m "data: exports" && git push` after each drop.

**PDPL:** aggregate rows only (by date/campaign/source/event). A file with user-level rows or PII columns gets refused by the loop and must be deleted, not committed.
