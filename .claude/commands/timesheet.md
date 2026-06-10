# Timesheet

Generate a weekly timesheet from git activity and calendar, then DM it to the user.

## Setup

Before doing anything else:

1. Read `context/about.md` to get:
   - The user's **Slack member ID** (used as the DM channel in step 6)
   - The **`## Work schedule`** section — this defines the working days and hours for the week

2. Read all files in `context/projects/` and extract the `**Local path:**` value from each file. These are the repos to check for git activity. Ignore any project file that has no `**Local path:**` value.

Use two non-project lines:
- **Internal meetings** — calendar meetings not discussing a client (standups, training, company-wide calls, etc.). Pull durations directly from the calendar.
- **Internal admin** — overhead, email, Slack, general admin. Target ~15% of total hours minus internal meeting time. Skew to lighter days.

## Steps

1. **Determine the current week.** Work out the dates for each working day in the current week based on the work schedule read from `context/about.md`.

2. **Check the calendar** using `outlook_calendar_search` with `afterDateTime` = first working day and `beforeDateTime` = day after last working day. Extract all events where the user is an attendee (not just organiser). Note:
   - Ignore "Non-Work Hours" blocks — these define when the user isn't working, not billable time
   - Ignore cancelled events
   - Internal meetings (team standups, Digital Bantz, training sessions, company-wide calls, any meeting not discussing a specific client) → **Internal meetings** line
   - Client/project meetings (SMF catch-up, Elastic, QVC calls, etc.) → count toward that project
   - Note meeting durations per day so they inform hour allocation

3. **Check git logs** for the working days across all repos extracted from `context/projects/` in the setup step. The local paths are relative to the user's home directory (or absolute if they start with `/`). For each repo, run:
   ```
   git log --format="%ad %s" --date=format:"%a %d %b" --after="[first working day]" --before="[day after last working day]"
   ```

4. **Allocate hours** by day and project based on commit volume, significance, and calendar events:
   - Weight hours toward days with heavier commit activity
   - If a day has commits in multiple repos, split proportionally
   - Days with only light commits or comms (no dev) should have more internal admin
   - Hours per day must exactly match the schedule from `context/about.md`

5. **Build the table** with this format (rows repeat for each working day; use the hours from `context/about.md` for each day's subtotal and the weekly total):

```
### 📊 Timesheet — week of [first working day date]

| Day | Code | Project | Notes | Hours |
|---|---|---|---|---|
| [Day] | [code] | [Project] | [what was done] | [h] |
| [Day] | — | Internal meetings | [meeting 1, meeting 2, ...] | [h] |
| [Day] | — | Internal admin | Email, Slack | [h] |
| **[Day]** | | | | **[day total]** |
...
| **TOTAL** | | | | **[week total]** |
```

One row per day per client/type. Multiple meetings of the same type on the same day are collated into one Notes cell (comma-separated). Project rows use the Maconomy code from the project's context file (`context/projects/`). Internal meetings and admin use `—` for the code. Omit the Internal meetings row on days with no internal meetings.

6. **Send as a Slack DM** to the user using `slack_send_message` with channel set to the Slack member ID read from `context/about.md`.

7. **Confirm** in the conversation that the DM was sent.

## Notes
- Only include projects where there was actual activity that day
- If a day had no dev commits (pure comms/meetings), allocate all non-admin hours to the most relevant project for that day's discussions
- Hours must add up exactly per day and in total, matching the schedule in `context/about.md`
