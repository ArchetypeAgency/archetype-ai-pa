# Timesheet

Generate a weekly timesheet table from git activity and DM it to Ryan.

## Standard week

- Monday: 7.5 hrs
- Tuesday: 7.5 hrs
- Wednesday: 3.75 hrs
- Thursday: 3.75 hrs
- **Total: 22.5 hrs** (no Fridays)

Use two non-project lines:
- **Internal meetings** — calendar meetings not discussing a client (standups, training, company-wide calls, etc.). Pull durations directly from the calendar.
- **Internal admin** — overhead, email, Slack, general admin. Target ~15% of total hours minus internal meeting time. Skew to lighter days.

## Steps

1. **Determine the current week.** Work out the Monday–Thursday dates for the current week.

2. **Check the calendar** using `outlook_calendar_search` with `afterDateTime` = Monday and `beforeDateTime` = Friday. Extract all events where Ryan is an attendee (not just organiser). Note:
   - Ignore "Non-Work Hours" blocks — these define when Ryan isn't working, not billable time
   - Ignore cancelled events
   - Internal meetings (team standups, Digital Bantz, training sessions, company-wide calls, any meeting not discussing a specific client) → **Internal meetings** line
   - Client/project meetings (SMF catch-up, Elastic, QVC calls, etc.) → count toward that project
   - Note meeting durations per day so they inform hour allocation

3. **Check git logs** for Mon–Thu across these repos (relative to `~/Sites/`):
   - `smf-movewhatmatters` — SMF Move What Matters
   - `archetype-uk-non-bedrock` — Archetype UK
   - `archetype-apac` — Archetype APAC
   - `elastic-dashboard` — Elastic C-Suite Dashboard
   - `qvc-core-wp-engine` — QVC
   - `qvc-careers-wp-engine` — QVC Careers

   For each repo, run:
   ```
   git log --format="%ad %s" --date=format:"%a %d %b" --after="[Mon date]" --before="[Fri date]"
   ```

4. **Allocate hours** by day and project based on commit volume, significance, and calendar events:
   - Weight hours toward days with heavier commit activity
   - If a day has commits in multiple repos, split proportionally
   - Days with only light commits or comms (no dev) should have more internal admin

5. **Build the table** with this format:

```
### 📊 Timesheet — week of [Mon date]

| Day | Code | Project | Notes | Hours |
|---|---|---|---|---|
| Monday | [code] | [Project] | [what was done] | [h] |
| Monday | — | Internal meetings | [meeting 1, meeting 2, ...] | [h] |
| Monday | — | Internal admin | Email, Slack | [h] |
| **Monday** | | | | **7.5** |
| Tuesday | [code] | [Project] | [what was done] | [h] |
| Tuesday | — | Internal meetings | [meeting 1, meeting 2, ...] | [h] |
| Tuesday | — | Internal admin | Email, Slack | [h] |
| **Tuesday** | | | | **7.5** |
| Wednesday | [code] | [Project] | [what was done] | [h] |
| Wednesday | — | Internal meetings | [meeting 1, meeting 2, ...] | [h] |
| Wednesday | — | Internal admin | Email, Slack | [h] |
| **Wednesday** | | | | **3.75** |
| Thursday | [code] | [Project] | [what was done] | [h] |
| Thursday | — | Internal admin | Email, Slack | [h] |
| **Thursday** | | | | **3.75** |
| **TOTAL** | | | | **22.5** |
```

One row per day per client/type. Multiple meetings of the same type on the same day are collated into one Notes cell (comma-separated). Project rows use the Maconomy code from the project's context file (`context/projects/`). Internal meetings and admin use `—` for the code. Omit the Internal meetings row on days with no internal meetings.

6. **Send as a Slack DM** to Ryan using `slack_send_message` with channel `UE253F4KU`.

7. **Confirm** in the conversation that the DM was sent.

## Notes
- Only include projects where there was actual activity that day
- If a day had no dev commits (pure comms/meetings), allocate all non-admin hours to the most relevant project for that day's discussions
- Hours must add up exactly: Mon 7.5, Tue 7.5, Wed 3.75, Thu 3.75, total 22.5
