# Google Search playbook (Manafa)

**Used by:** bi-paid-media-review, paid-search query mining (Phase 1). Operating rules for reading and advising on Manafa's Google Search campaigns. The agent recommends; a named human changes the account.

Adapted from `ads/references/google-search-playbook.md` in coreyhaines31/marketingskills (MIT), itself adapted from practitioner playbooks. The upstream version is written for B2B SaaS; SaaS benchmarks, CRM/SQL language and PMax-for-B2B advice were removed. Provenance in `context/upstream-skills.md`.

## The intent ladder

Spend opens rung by rung. Each tier earns budget only after the one below proves it produces **funded investors**, not just registrations:

1. **Brand:** Manafa's name in Arabic and English, plus brand + app / login / reviews. Cheapest clicks, highest conversion.
2. **High-intent non-brand:** people ready to invest ("investment platform Saudi", "crowdfunding investment", sukuk / murabaha / Sharia-compliant investing, in Arabic and English).
3. **Competitor:** other licensed platforms' names. Higher cost, lower conversion. Only with compliant comparison messaging; CMA advertising rules apply.
4. **Problem-aware:** "where to invest savings", "passive income Saudi". Longer path to a deposit.
5. **Awareness:** Display, YouTube, Demand Gen. Last, with spare budget only.

## Brand: measure it separately

- Report brand and non-brand as separate lines, always. Brand's cheap conversions make blended numbers look healthy while non-brand is weak.
- Brand gets its own budget, never shared: in a shared budget brand starves the campaigns you need data from.
- **The pause test** (incrementality) is the only way to know what brand search adds. Watch total brand conversions (paid + organic), not paid alone. It is a spend change, so it needs human approval and a measurement plan (`ab-testing`, Phase 2).

## Account structure to look for

- Separate campaigns, each with its own budget: brand, non-brand high-intent, competitor, remarketing, App campaigns.
- Themed ad groups of 5–15 keywords sharing one intent and one landing page.
- A campaign that can't reach ~15–30 conversions a month can't feed Smart Bidding. Consolidation is a likely recommendation.
- Settings worth checking: Search Partners and Display expansion off until proven; location set to **Presence** (people in Saudi Arabia, not people "interested in" it).
- **Language targeting follows the user's Google interface language, not the query language.** Many Saudi users run Google in English and search in Arabic, or the reverse. Arabic-only or English-only targeting can quietly exclude real searchers.
- The same keyword and match type in several ad groups splits data and bids against itself.

## Match types

1. Start high-intent terms on Phrase + Exact.
2. Mine the search-terms report weekly (below).
3. Broad match only when the campaign has 30+ conversions a month, Smart Bidding is live, and the negative list is tight. AI Max for Search follows the same gate; if tested, check which landing pages it chose.

## Negatives

- Starter themes: jobs / careers / salary, courses / training, free, PDF, definitions ("what is", "meaning"), loans and financing (Manafa's investor funnel isn't for borrowers; issuer traffic is a separate B2B audience).
- Brand as a negative in non-brand campaigns, so brand queries route to the brand campaign.
- Negative broad needs all its words present; negative phrase blocks the phrase in order; negative exact blocks only that query. Most over-blocking traces to this.
- Negative the clearly wrong, not the merely uncertain. **Never propose negatives without a search-terms export** (`ads-audit-guardrails.md`).

## The weekly search-terms ritual (the query-mining loop, Phase 1)

Per campaign, three passes, each staged for human review:
1. **Waste:** terms with 3+ clicks and zero conversions, irrelevant to investing → candidate negatives. Check break-even CVR and sample size first (`reading-google-ads-data.md`).
2. **Winners:** converting terms that aren't keywords yet → candidate Exact/Phrase keywords.
3. **Drift:** broad or phrase matches pulling wrong meanings → tighten or negative.

State tracks every proposed and applied negative so nothing is proposed twice.

## Bidding by conversion volume

| Conversions per month (campaign) | Typical strategy |
|---|---|
| 0–15 | Manual CPC or Maximize Conversions (no target) |
| 15–30 | Maximize Conversions |
| 30+ stable | Target CPA, set at or slightly above the trailing 30-day actual |
| Real values flowing back | Target ROAS |

Targets move in ±10–15% steps with 1–2 weeks between changes; every change restarts learning.

## The optimize-to-quality trap (the Manafa version)

Bidding on `registration_completed` teaches Google to find people who register, not people who invest. Web loses about three quarters of registrants before KYC (Singular cohort, Oct 20 – Nov 2). So a campaign can look cheap per registration and be expensive per funded investor. Two consequences:

- Always report each campaign's downstream outcomes (KYC, deposit) from the source that has them, in that source's own section. Never divide Google Ads spend by another tool's count (source-separation rule).
- The structural fix is to bid on a deeper event (KYC or first deposit), via app postbacks or an offline import from the backend. Both need a tracking owner, and an import of identifiers needs PDPL review first.

## Weekly scorecard (per campaign type, brand and non-brand apart)

Spend · clicks · CTR · CPC · conversions by action · cost per conversion by action · Search impression share · Search lost IS (budget) vs lost IS (rank) · disclosed-clicks ratio · top wasted terms.

Lost IS (budget) means capped by money; lost IS (rank) means capped by Ad Rank or Quality Score. Different problems, different fixes.
