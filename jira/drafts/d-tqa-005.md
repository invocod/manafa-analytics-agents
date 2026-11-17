# [UI][Web] Withdrawal reference number is sent to GA4 in the page path (/entrepreneur/transactions/withdraw/…)

- Type: Bug · Priority: High · Parent: ISQ-6052
- Dev Assignee: Khalid Shabbir
- Labels: bi-agent, analytics, ga4, compliance, tqa-005
- Tracking: tqa-005
- Status: CREATED as ISQ-6059 (approved by Amir 2026-11-17)

## Problem
The web page path `/entrepreneur/transactions/withdraw/MWWD<16–18 digits>` is sent to GA4 as-is. The number is a **withdrawal (transaction) reference**. Under SAMA/PDPL handling rules, transaction references shouldn't leave Manafa's systems in analytics data.

## Impact
- Compliance: transaction identifiers are stored in Google Analytics (third party, outside Saudi Arabia).
- Analytics: one page row per transaction inflates cardinality in GA4.

## Evidence (aggregated, masked)
GA4 Pages & Screens, 9–14 Nov: path `/entrepreneur/transactions/withdraw/MWWD<ID>`, page title "منصة الدين", 54 views. Earlier weeks: 129 rows with 16–18-digit IDs in page paths or titles. No actual reference numbers are included in this ticket.

## Likely root cause
The GA4 config tag sends the full `page_location` / `page_path` by default. The withdrawal detail route puts the reference in the URL.

## Suggested fix
- Before sending, replace IDs in the path with a template, e.g. `/entrepreneur/transactions/withdraw/:ref`, in the GA4 config (`page_location` override) or the router's page-view call.
- Apply the same rule to every route that carries a transaction, document or account identifier (check `/transactions/`, `/documents/`, `/wallet/`).
- Ask GA4 admins whether past data with references should be deleted (GA4 data-deletion request). Involve compliance.

## Ownership note
This is the **entrepreneur (borrower) side** of the web app. If it belongs to the debt-platform squad rather than the Investor Squad, please move it.

## Acceptance criteria
Zero GA4 page paths or titles containing 12+ consecutive digits for a full week.

## How the BI agent will verify
Weekly regex check on GA4 Pages & Screens (`bi-tracking-health`). Only counts are reported, never the values.

_Filed by the Manafa BI agent (decision support)._
