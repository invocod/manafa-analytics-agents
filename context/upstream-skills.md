# Upstream skills: what was borrowed, from which version

This agent adapts material from [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) (MIT License, © 2025 Corey Haines). Nothing is used verbatim: every piece was rewritten for Manafa (backend truth, source separation, SAMA/PDPL, read-only accounts). The table records what each local file came from, so upstream changes can be reviewed against it.

## Reviewed snapshot

| | |
|---|---|
| Upstream commit | `1f83744` (2026-11-11) |
| Reviewed on | 2026-11-12 |
| Reviewed by | agent, for Amir (Phase 0 approval, 2026-11-12) |

## Mapping

| Local file | Upstream source | Upstream version |
|---|---|---|
| `CLAUDE.md` operating rules, all `.claude/skills/*` loop structure | `marketing-loops` (+ `references/loop-template.md`, `loop-state.md`, `loop-guardrails.md`) | 1.8.4 |
| `CLAUDE.md` source-of-truth and reconciliation rules; `attribution-recon` | `attribution` | 1.1.9 |
| `CLAUDE.md` data discipline; `analytics-anomaly`, `funnel-health` | `analytics` | 2.2.5 |
| `CLAUDE.md` discrepancy verdicts; `tracking-qa` | `conversion-tracking` | 1.0.6 |
| `context/playbooks/google-ads-conversion-audit.md` | `conversion-tracking/references/google-ads.md` (Part B) + `discrepancies.md` | 1.0.6 |
| `context/playbooks/reading-google-ads-data.md` | `ads/references/reading-google-ads-data.md` | 2.7.5 |
| `context/playbooks/ads-audit-guardrails.md` | `ads/references/audit-guardrails.md` | 2.7.5 |
| `context/playbooks/google-search-playbook.md` | `ads/references/google-search-playbook.md` | 2.7.5 |
| `context/playbooks/ga4-event-standards.md` | `analytics/references/ga4-implementation.md` + `event-library.md` | 2.2.5 |

The four base skills were first adapted on 2026-11-10/11 from an earlier upstream state. The versions above are what was current at this review; their reference files had not been used before Phase 0.

## Deliberately not used

- **Upstream CLIs** (`tools/clis/ga4.js`, `google-ads.js`). They include write commands: `campaigns pause|enable`, `budgets update`, `conversions create`, and `events send`, which injects Measurement Protocol events into production GA4. If API access replaces CSV drops, use read commands only, with read-only access: GA4 `analytics.readonly` scope; Google Ads via a user with Read-only access role (the Ads API scope can't be limited to reading).
- **Singular:** upstream has no Singular tool, integration or reference. Singular checks are Manafa's own.
- **SaaS framing:** LTV:CAC, ARPU payback, trials, MQL/SQL, PMax-for-B2B benchmarks.

## Planned for later phases

| Phase | Upstream source | Use |
|---|---|---|
| 1 | `marketing-loops` loop catalog: paid-search query mining | New weekly loop, staged negatives only |
| 2 | `ab-testing` (+ `references/sample-size-guide.md`) | Measurement plans for fx-01 and funnel-health proposals |
| 2 | Loop catalog: landing-page regression | GA4 page-path driven loop |
| 3 | `attribution/references/measurement-paradigms.md`, `ads/references/payback-period.md` | Incrementality and payback, after BigQuery |

## How to check for upstream changes

1. Read upstream `VERSIONS.md` and compare it against the version column above.
2. For each changed source, diff it against the reviewed commit:
   ```
   git diff 1f83744..main -- skills/<name>
   ```
3. Port only changes that fit Manafa's rules. Then update this table and the commit line.
