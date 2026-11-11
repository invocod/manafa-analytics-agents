# GA4 event & parameter health — 2026-11-11

**Verdict: the money events are healthy, but six account and identity events are very likely counted twice in the apps.** That includes `registration_completed`, the event the ad platforms optimize on. Parameter health can't be judged from the current exports (Recipe D needed).

Sources: GA4 Engagement overview event lists (Oct 20–Nov 10, 183 event names; Nov 4–10, 152), the GA4 snapshot (key events by platform) and the Singular aggregate (Oct 19–Nov 9, one day earlier). All counts are computed by script from the exports. Aggregates only.

## 1. Money events reconcile (Observed)
Singular ÷ GA4: deposit_success 1.00 · investment_completed 0.92 · withdrawal_settled 0.94 · deposit_failed 0.96 · investment_cancelled 0.98 · email_verified 0.99 · auto_invest_enabled 0.99 · withdrawal_failed/reversed 1.00. These are the server-confirmed outcomes, and both tools agree.

## 2. Six events look doubled in the apps (Inferred, strong)
| Event | GA4 | Singular | Model error if: no doubling | apps ×2, web ×1 |
|---|---|---|---|---|
| registration_completed | 3,010 | 1,908 | −36.6% | **+4.6%** |
| kyc_completed | 2,960 | 1,562 | −47.2% | **−3.5%** |
| login_completed | 112,309 | 58,283 | −48.1% | **+1.8%** |
| withdrawal_completed | 6,795 | 3,434 | −49.5% | **−0.7%** |
| passcode_enabled | 894 | 464 | −48.1% | **+3.2%** |
| bank_account_added | 864 | 495 | −42.7% | **+9.4%** |

Independent evidence inside GA4 (Observed): withdrawal_completed 6,795 is more than withdrawal_started 3,703 and about 2× withdrawal_settled 3,543. In Singular, completed and settled are about equal. kyc_completed 2,960 is more than kyc_started 1,744. **Impact:** the interim ledger overstates registrations by ~1.6× and KYC by ~1.9×. If Google Ads imports app `registration_completed`, bidding sees doubled conversions. **Confirm:** Recipe B (event × stream × platform, event count vs total users). Updates tqa-007.

## 3. Tracking changed around Nov 1–3 (Observed timing, Inferred cause)
- `deposit_started` per day fell 62% (619 → 236), while `deposit_success` fell only 24%. Started→success jumped from 0.18 to 0.31. A definition change, not a behaviour change.
- Singular started receiving `*_started` events on Nov 2 (deposit, registration, kyc, investment, withdrawal).
- `screen_view` per day +60%. Total daily events stepped up from about 70–99k (Oct) to 94–136k (from Nov 1).
- Matches tqa-008 (an app release ~Oct 30–Nov 3). Trends in these events across that date are breaks, not behaviour changes.

## 4. Two naming schemes live side by side (Observed)
31 legacy Title_Case events (1.8% of volume) duplicate the snake_case taxonomy. Examples: `Logged_in` / `login_completed`, `Investment_Made` / `investment_completed`, `Deposit_Successful` / `deposit_success`, `KYC_Completion` / `kyc_completed`, `Opportunity_Details_View` / `opportunity_view`. They are declining (~30–45% per day lower this week), consistent with old app versions still in use (Inferred). Defects: `Withdrawal_Click` = `Withdrawal_Success` exactly (407/407, 82/82), so one fires on the other's trigger. Typos: `Wakalla_` vs `wakala_`, `Unfavorite_Opportunity_` (trailing underscore). Metric-like event names: `prompt_display_rate`, `vote_distribution_percentage`. Volume is safely under the 500-name limit (183).

## 5. Key-event set is wider than the funnel (Observed)
Key events (snapshot): 57,805 = iOS 31,791 · Android 13,843 · web 12,171. That is 2.4× the four funnel events (23,947), so other events are also marked as key events. Which ones can't be identified (32 combinations fit the total); check Admin → Events. "Key events" in channel reports is not a funnel count.

## 6. Product signals (not tracking — route to funnel-health)
deposit_failed = 28% of deposit outcomes (32% this week). app_exception 3,093 (~3.9 per 100 sessions).

## Not assessed — parameters
No export carries event parameters. Recipe D (`context/ga4-explore-recipes.md`) measures `(not set)` rates per custom dimension and whether deposit/investment events carry a value, without exporting parameter values (PDPL-safe). A full parameter audit needs the BigQuery `event_params` export.

## Housekeeping
The earlier 22-day export had a partial Nov 10 (94,058 events vs 109,649 in the new file). That's another reason the trailing 72 hours are never judged. Effect on the 22-day totals is ~0.8%.
