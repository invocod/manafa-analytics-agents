# marketing_mart — admin runbook (Phase 0)

**Why:** loops, dashboards and Looker Studio should read only aggregated, PII-free views. Today the agent's
BigQuery user can reach `silver`, `manafa_financing` and other datasets that hold customer data. PDPL/SAMA compliance
should be enforced by permissions, not by instructions.

**Status (2026-11-16): DEFERRED to the deploy phase.** Amir has read-only BigQuery access; until deployment, loops use the identical logic as read-only queries in `sql/readonly/`. Original status: SQL written and every view body validated read-only against live data. The dataset is **not created yet**:
Amir's account lacks `bigquery.datasets.create`. A GCP admin runs the steps below once.

All objects stay in **`me-central2` (Saudi Arabia)**. Do not create anything in another region.

## 1. Create the dataset and views

```bash
for f in 00_create_dataset.sql 01_backend_events_daily.sql 02_event_delivery_health_daily.sql \
         03_investor_funnel_cohorts_weekly.sql 04_ga4.sql 05_google_ads.sql 06_source_freshness.sql; do
  bq query --project_id=databases-472111 --location=me-central2 --use_legacy_sql=false < "$f"
done
```

| View | Source | Grain |
|---|---|---|
| `backend_events_daily` | `manafa_financing.mi_analytics_events` | Riyadh day × event × platform × acquisition × currency |
| `event_delivery_health_daily` | `mi_analytics_event_deliveries` + events | day × event × platform × vendor × status × degraded_reason |
| `investor_funnel_cohorts_weekly` | `gold.fact_investor_journey` | signup ISO week × channel × utm_source |
| `ga4_events_daily`, `ga4_traffic_daily`, `ga4_user_acquisition_daily` | `GA4` transfer (property 413046941) | report day × dimension |
| `gads_campaign_daily`, `gads_conversions_daily` | `google_ads` transfer (customer 3343082801) | day × campaign (× action) |
| `source_freshness` | all of the above | latest date per source |

## 2. Authorize the mart on the source datasets

So that readers of `marketing_mart` never need access to the raw datasets, add `marketing_mart` as an
**authorized dataset (views)** on each source dataset: `manafa_financing`, `gold`, `GA4`, `google_ads`.
Console: source dataset → Sharing → Authorize datasets → `databases-472111.marketing_mart`.

## 3. Dedicated identity for the agent

```bash
gcloud iam service-accounts create marketing-bi-agent --project=databases-472111 \
  --display-name="Marketing BI agent (read-only, marketing_mart)"
SA=marketing-bi-agent@databases-472111.iam.gserviceaccount.com
# run queries (billing) in the project
gcloud projects add-iam-policy-binding databases-472111 --member="serviceAccount:$SA" --role=roles/bigquery.jobUser
# read ONLY the mart: Console → marketing_mart → Sharing → Permissions → add $SA as BigQuery Data Viewer
```

Do **not** grant the agent project-level Data Viewer. Optionally apply the same restriction to the human account
used by the Claude BigQuery connector (dataset-level Data Viewer on `marketing_mart` + Job User), so the
connector itself can't reach customer tables.

## 4. Verify

```sql
SELECT * FROM `databases-472111.marketing_mart.source_freshness`;
-- as the service account, this must FAIL (Access Denied):
SELECT 1 FROM `databases-472111.silver.customer_name` LIMIT 1;
```
