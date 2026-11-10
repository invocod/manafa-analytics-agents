# Manafa UTM & Campaign Naming Convention

This is the single allowed-values registry. Build every link from it; the tracking-QA loop audits live traffic against it.

## Rules (non-negotiable)

1. **Lowercase everything.** GA4 treats `Snapchat` and `snapchat` as two sources and the split never merges back.
2. **Hyphens between words.** No spaces, underscores, or `+`.
3. **One spelling per source.** `snapchat`, never `snap` or `sc`. The tables below are the only allowed values.
4. **No personal data in UTMs — ever.** No emails, names, phone numbers, or user IDs (PDPL + Google's GA4 terms).
5. **One link per placement.** Two posts by the same creator = two links; the campaign value rolls them up.
6. **Test the final URL** after shorteners/redirects before the campaign ships.

## utm_source allowed values

`google`, `meta`, `tiktok`, `snapchat`, `twitter`, `linkedin`, plus one value per named partner/newsletter/podcast (lowercase, hyphenated, registered below).

## utm_medium allowed values → GA4 channel

| utm_medium | Use for | GA4 custom channel |
|---|---|---|
| `cpc` | paid search & paid social | Paid Search / Paid Social (default) |
| `creator` | paid influencer/creator deals (NOT `social`, NOT `video`) | **Creators** (custom rule) |
| `affiliate` | affiliate deals | Affiliates |
| `newsletter` | paid newsletter placements | **Newsletters** (custom rule) |
| `podcast` | podcast sponsorships | **Podcasts** (custom rule) |
| `community` | community placements | **Community** (custom rule) |
| `email` | own lifecycle email | Email |
| `referral-program` | in-product referral links | **Referral program** (custom rule) |

## Campaign naming pattern

```
utm_campaign = {objective}-{audience}-{offering?}-{yyyy}-{mm}
e.g. registrations-investors-2026-11, deposit-retargeting-sukuk-x-2026-11
```

`utm_content` = placement/creative: `{placement}-{yyyy-mm-dd}` or the creative/video ID.

## Partner patterns

| Partner type | utm_source | utm_medium | utm_campaign | utm_content |
|---|---|---|---|---|
| Creator (TikTok, Snapchat, YouTube) | `{platform}` | `creator` | `{creator-name}` | post date or video ID |
| Newsletter | `{partner}` | `newsletter` | `{partner}-{yyyy}-{mm}` | `{placement}-{yyyy-mm-dd}` |
| Podcast | `{podcast}` | `podcast` | `{podcast}-{yyyy}-{mm}` | `{spot}-{yyyy-mm-dd}` |
| Affiliate | `{partner}` | `affiliate` | `{partner}-affiliate` | placement |

## GA4 custom channel group (fixes "Unassigned")

GA4's default grouping sends `creator`, `newsletter`, `podcast`, `community`, `referral-program` mediums to **Unassigned**. A custom channel group with one rule per medium above is required, plus:

- **AI assistants channel**: rule matching referrers `chatgpt.com`, `perplexity.ai`, `gemini.google.com`, `copilot.microsoft.com`, and `utm_source` values assistants add. Treat it as a floor — most AI-influenced visits arrive as direct or branded search.
- **Snapchat**: verify Snapchat ads traffic carries `utm_source=snapchat&utm_medium=cpc`; without UTMs, Snapchat's in-app browser often strips the referrer → Unassigned.

TODO: confirm the custom channel group exists in GA4 and matches this table (tracking-QA loop checks this).

## Partner registry

| Partner | utm_source value | Type | Active since |
|---|---|---|---|
| TODO | | | |
