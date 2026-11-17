# [UI][Web] Localhost, Netlify-preview and Tag Assistant traffic is recorded in production GA4

- Type: Bug · Priority: Low · Parent: ISQ-6052
- Dev Assignee: Khalid Shabbir
- Labels: bi-agent, analytics, ga4, tqa-015
- Tracking: tqa-015
- Status: CREATED as ISQ-6061 (approved by Amir 2026-11-17)

## Problem
Production GA4 (property 413046941) receives sessions whose source is a developer or preview host.

## Impact
Small in volume (the top 15 such sources alone = 43 sessions on 9–14 Nov), but it pollutes the referral channel and can fire test conversions in production.

## Evidence (aggregated, 9–14 Nov sessions by source)
- `127.0.0.1:<port>`: many different ports (8034–8874), mostly 2 sessions each; 202 distinct ports were seen in the week of 9 Nov.
- `manafa-3billion.netlify.app`: 4 · `manafa-help-center.netlify.app`: 2 · `tagassistant.google.com`: 2.

## Likely root cause (inferred)
1. Netlify preview and branch deploys use the production GA4 measurement ID.
2. `tagassistant.google.com` is GTM/GA debugging against production.
3. `127.0.0.1:<random port>`: probably local dev servers using the prod measurement ID. **However**, the large number of different ports could instead come from the mobile app serving web content from an in-app localhost server (e.g. a WebView local server) and linking to the website. Please check with Azib.

## Suggested fix
- Load the production GA4 tag only when the hostname is a production domain. Previews and localhost use a separate dev measurement ID or no tag.
- In GA4 admin: define internal/developer traffic and activate the data filter. Add the preview hosts to the unwanted-referrals list.

## Acceptance criteria
Zero sessions from `127.0.0.1`, `*.netlify.app` and `tagassistant.google.com` in production GA4 for a full week (or the localhost source explained as the app and handled there).

## How the BI agent will verify
Weekly source check on the GA4 traffic-acquisition table (`bi-tracking-health`).

_Filed by the Manafa BI agent (decision support)._
