-- Run by a GCP admin (needs bigquery.datasets.create). Saudi residency: me-central2 only.
CREATE SCHEMA IF NOT EXISTS `databases-472111.marketing_mart`
OPTIONS (
  location = 'me-central2',
  description = 'Manafa marketing BI mart: AGGREGATED views only (no PII, no row-level users). Sole input for marketing loops, dashboards and Looker Studio. Residency: me-central2 (Saudi Arabia).',
  labels = [('owner', 'marketing-bi'), ('pii', 'none'), ('residency', 'sa')]
);
