# Loop State

One `<loop>.json` (memory) + `<loop>.log` (append-only run log) per loop. Loops read their state before acting and commit updates after every run — this is what stops double-alerts, re-filed issues, and re-proposed fixes.

Rules (from the marketing-loops skill):

- **Watermark**: process only data newer than `cursor`; advance it only after a successful run.
- **Dedupe**: check `handled`/`active_anomalies`/`open_issues` before acting; update after.
- **First run**: set the watermark to now — don't backfill history without a dry run.
- **Run log line per run, acted or not**: `2026-11-17T06:00Z checked=12 acted=1 note="..."` — plus `decision:` lines when a run changed what happens next. Weeks of `acted=0` that nobody misses = a vanity loop; reconsider it.
- **Never any PII** in state or logs — aggregate metrics and issue ids only.
- To reset a loop, clear `cursor`, keep cooldowns.
