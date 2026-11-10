# Manual CSV exports drop zone

Ad-platform (and optionally backend) exports land here; loops read the freshest file per platform and treat anything older than 8 days as stale.

```
data/exports/google-ads/google-ads-2026-11-10.csv
data/exports/meta/meta-2026-11-10.csv
data/exports/tiktok/…   data/exports/snapchat/…   data/exports/backend/…
```

Formats are specified in `context/data-sources.md`. Weekly, by campaign: `date,campaign,spend_sar,impressions,clicks,conversions,conversion_action`.

**Export → commit → push** (the cloud loops read the GitHub repo, not anyone's laptop):

```bash
git add data/exports && git commit -m "data: weekly platform exports" && git push
```

Aggregate campaign rows only — never export anything row-level or customer-identifying into this repo.
