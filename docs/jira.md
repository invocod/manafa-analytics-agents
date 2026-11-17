# Jira: tracking issues → Investor Squad tickets (ISQ-6052)

Set up 2026-11-17 with Amir. Tracking and data-quality problems the BI loops find (`tqa-*` in `state/bi-tracking-health.json`) that a squad developer must fix become Jira tickets under **epic ISQ-6052** ("Business Intelligence platform issues", project ISQ, site manafaco.atlassian.net).

## Who gets what (confirmed by Amir 2026-11-17)
| Area | Summary prefix | Dev Assignee (`customfield_10055`) | accountId |
|---|---|---|---|
| Mobile | `[App]` / `[API][App]` / `[UI][App]` | AzibMuzammil | 712020:51fb9b58-a539-4130-9391-d2be6467ad7b |
| Backend | `[BE]` | Mohammad Khubaib | 62b0783ecebad33432f5e0ce |
| Web | `[UI][Web]` / `[API][Web]` | Khalid Shabbir | 712020:523e0199-eda3-4211-b807-efb682355023 |

The Jira **Assignee** field is left for the squad's own flow (QA). Only Dev Assignee is set.

## Not squad tickets (stay on the tracking board only)
Data engineering (tqa-012), paid media / Google Ads (tqa-016), performance marketing / Singular (tqa-018), marketing UTM work (tqa-002, tqa-003), event-standard owner (tqa-011), monitoring items (tqa-001, 008, 009, 010). The list lives in `state/bi-tracking-health.json` → `jira.outside_squad` and on the Command Center Jira tab.

## Lifecycle (decision support — a human approves every Jira write)
1. **Draft.** When bi-tracking-health files or updates a squad-owned issue, it writes a draft to `jira/drafts/drafts.json` + `jira/drafts/<draft_id>.md` and to the Command Center (`jira_drafts/<draft_id>`, `status:"staged"`). One draft per area per issue; an issue can need two (e.g. tqa-014 app + backend).
2. **Approve.** Amir approves in chat (all, or by draft id). Nothing reaches Jira before that.
3. **Create.** Claude creates the ticket: project ISQ, parent ISQ-6052, issue type from the draft, summary, description, priority, labels (`bi-agent`, the tqa id, topic), Dev Assignee. Then it records the key in `state/bi-tracking-health.json` → `jira.tickets[<draft_id>] = {key, created}` and sets the draft's `jira_key` and `status:"created"` in the Command Center.
4. **Never duplicate.** Before drafting, check `jira.tickets` and the live epic (`parent = ISQ-6052 AND labels = <tqa-id>`). If a ticket exists, update the draft text for the next human review instead of filing again.
5. **Verify.** When the check named under "How the BI agent will verify" passes for its full window, the loop drafts a short "verified fixed by data" comment (numbers only). It's posted after approval. The loop never changes ticket status, priority or assignee.

## Description template (every ticket)
Problem · Impact · Evidence (aggregated, with dates; never customer data, IDs or amounts tied to people; mask identifiers like `MWWD<ID>`) · Likely root cause (ranked, marked *inferred*) · Where to look · Suggested fix · Acceptance criteria · How the BI agent will verify · footer "Filed by the Manafa BI agent (decision support)".

## Connector
Use the **Atlassian MCP** connector (current endpoint). The older "Atlassian" and "Atlassian Rovo" connectors run on the deprecated V1 endpoint (removed 2027-03-01). The Command Center Jira tab reads with `searchJiraIssuesUsingJql` (read-only, `view:"full"` so dates come back).
