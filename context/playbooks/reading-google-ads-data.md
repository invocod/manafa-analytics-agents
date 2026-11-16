# Reading Google Ads data without false conclusions (Manafa)

**Used by:** bi-paid-media-review, paid-search query mining (Phase 1), bi-campaign-health. Load before analysing or reporting any Google Ads export.

Adapted from `ads/references/reading-google-ads-data.md` in coreyhaines31/marketingskills (MIT). Provenance in `context/upstream-skills.md`.

Google Ads reports leave data out without saying so, names suggest contents they don't have, and small campaigns produce numbers that look like findings. Most wrong conclusions come from that, not from bad reasoning.

## What the export hides

- **Search terms are a sample.** Google withholds low-volume queries. Often half or more of clicks have no disclosed search term. Every claim about "what this campaign is buying" carries the ratio: *disclosed clicks ÷ total clicks* for the same campaign and window. Export the report unfiltered (filters like `clicks > 0` drop impression-only terms). Nothing recovers withheld queries, GA4 included.
- **Names are labels someone typed once.** A campaign called "Brand" can hold non-brand keywords. Read the keywords and search terms before trusting a name.
- **"Conversions" is several actions in one column.** It counts every Primary action plus any action a campaign's custom goal pulls in. Segment by conversion action before calling anything a registration or a deposit (see `google-ads-conversion-audit.md`). At Manafa today, registration is the bid-on action and may be doubled in the apps (tqa-007).
- **Dates are click dates.** A deposit recorded today can be dated to a click last week. Say "clicked on Nov 4", not "converted on Nov 4". Never judge the trailing 72 hours.
- **Identical campaign names are usually experiment arms.** Expired arms keep the base name and can show ENABLED while serving nothing. Check experiment type and serving status before calling them duplicates.
- **Change history is short.** Field-level detail for 30 days, which-resource-changed for 90, nothing after that. A shift four months ago may have no recoverable explanation; say so.
- **Other people change the account.** Agency staff, automated rules, scripts and Google's auto-applied recommendations all leave changes. Report the change source, not a guess at who or why.
- **Several landing pages per ad group.** Ads carry their own final URLs; old pages stay in rotation. Check which destinations serve before judging a landing page.

## The window is not the picture

- Establish how long a campaign has run before quoting efficiency. Quote recent and lifetime figures when they diverge.
- Don't pool across configuration changes. If bids, budget, keywords, ads or targeting changed mid-window, the period is several experiments averaged together.
- Bid-strategy **learning** status = don't judge performance on it. Fixing a verified break (tracking down, wrong URL) still comes first.
- Manafa demand is **offering-driven**. A week with an attractive offering open converts differently from one without. Check the offering calendar before calling a trend.

## Small numbers

Zero conversions in N clicks only rules out conversion rates at or above this (95% confidence):

| Clicks | Rules out CVR ≥ | What you can say |
|---|---|---|
| 5 | 45% | Nothing |
| 10 | 26% | Still nothing useful |
| 30 | 10% | Can begin doubting a strong CVR |
| 50 | 6% | Meaningful for high-intent search |
| 100 | 3% | Underperforming if break-even CVR is above 3% |

Before calling spend wasted, work out what it would need to convert at:

```
break-even CVR = CPC ÷ target cost per registration (or per funded investor)
```

Manafa has **no formal targets yet**, so use the campaign's own trailing 8-week median cost per conversion as the stand-in, and label it as such. If break-even CVR is below what the traffic could plausibly do, the term isn't failing, it's unmeasured. Then say when a readable sample will exist at current volume.

## Stating findings

Every claim is one of:
- **Verified:** computed from this week's export, unfiltered, reconciled against the campaign total. (In the repo's Observed / Reported / Inferred scheme: Observed.)
- **Inferred:** reasoned from verified data, could be wrong.
- **Stale:** from an earlier report or someone's recollection. Carry its date: *as of the Nov 11 report*.

The test before a finding leaves the agent: could the marketing team disprove it in a minute with their own account access? Volunteer the limits first (disclosed-clicks ratio, sample size, config changes).

## Conclusions that sound right

| Sounds like | Usually |
|---|---|
| "This campaign has zero conversions" | True on the day the report was written |
| "The search terms are junk" | You're seeing part of the clicks |
| "That ad group is wrong intent" | It's *named* that; the keywords say otherwise |
| "X SAR wasted on those terms" | Below any readable sample size |
| "It converted, so the term works" | One conversion on one click is noise |
| "Performance fell this week" | Bids changed, or last week had an offering open |
| "It got a registration" | It got a conversion; check which action |
| "Google Ads registrations are up" | Check whether the action is a GA4 import (tqa-007) |
