# [UI][Web] Internal website links put placement names in utm_source (download_app_modal, article, mid_page…)

- Type: Bug · Priority: Medium · Parent: ISQ-6052
- Dev Assignee: Khalid Shabbir
- Labels: bi-agent, analytics, utm, tqa-004
- Tracking: tqa-004
- Status: STAGED (awaiting approval)

## Problem
Some links on Manafa's own website add `utm_source=<placement name>` (no medium). When a visitor clicks one, GA4 starts a new session and overwrites the visitor's real source (Google, X, TikTok…) with the placement name.

## Impact
Paid and organic traffic is under-credited, and junk sources appear in channel reports ("Unassigned"). It also breaks first- vs last-touch analysis.

## Evidence (aggregated, GA4 sessions 9–14 Nov, source / medium)
`send_message_to_scf_borrower` / (not set) 22 · `download_app_modal` / (not set) 13 · `article` 8 · `x` / (not set) 4 · `mid_page` 2 · `invite_a_friend` 3 · `hero` 1. Earlier weeks also had `jbyyfg` (146 in one week, looks like a typo'd link), `wallet`, `documents`.

## Likely root cause
CTAs, modals and blog/article links use UTM parameters to track *placement* on internal links. UTMs should only be used on links that bring people **from outside** the site.

## Suggested fix
- Remove UTM parameters from all internal links (same domain, and website → web app).
- Track placement with a GA4 event parameter instead (e.g. `cta_click` with `placement=download_app_modal`), per the event standard. Or use `utm_content` only on external links.
- Find and fix the `jbyyfg` link. Check whether `send_message_to_scf_borrower` comes from a message template (it may be a borrower-side email/SMS link; if so, use `utm_medium=email|sms` and `utm_source=manafa`).
- Follow `context/utm-convention.md` (lowercase; source = where, medium = how, campaign = why).

## Acceptance criteria
No GA4 sessions with these placement names as source for a full week.

## How the BI agent will verify
Weekly UTM convention check (`bi-tracking-health`).

_Filed by the Manafa BI agent (decision support)._
