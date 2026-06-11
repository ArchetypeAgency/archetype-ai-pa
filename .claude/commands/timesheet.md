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

5. **Build the table** — pivot format. One row per project, working days as columns:

```
### 📊 Timesheet — week of [first working day date]

| Job No. | Job Name | Task | Text | Mon | Tue | Wed | Thu | Total |
|---|---|---|---|---|---|---|---|---|
| [code] | [Project name] | Digital | [what was done] | [h] | [h] | | | [h] |
| [code] | [Project name] | Digital | [what was done] | | [h] | [h] | | [h] |
| [code] | Internal Project - Admin | Internal Meetings | [meeting names] | [h] | | | | [h] |
| [code] | Internal Project - Admin | Internal Admin | Email, Slack | [h] | [h] | [h] | [h] | [h] |
| | | | **Total** | **[h]** | **[h]** | **[h]** | **[h]** | **[h]** |
```

- **Columns:** Job No. | Job Name | Task | Text | Mon | Tue | Wed | Thu | Total
- Only include the working days from `context/about.md` (e.g. Ryan works Mon–Thu, no Fri)
- One row per project. If a project spans multiple days, fill in each day's hours across the row.
- Leave day cells blank (not 0) when no work was done on that project that day.
- **Task** values: `Digital` for client dev work; `Internal Admin` for overhead; `Internal Meetings` for non-client meetings
- **Job No.** uses Maconomy code from `context/projects/`. For internal rows, use the internal admin job code if known — otherwise leave blank.
- Hours per column must sum to the scheduled hours for that day (from `context/about.md`)
- Total column = sum of all day columns for that row

6. **Send as a Slack DM** to the user using `slack_send_message` with channel set to the Slack member ID read from `context/about.md`.

7. **Confirm** in the conversation that the DM was sent.

## Notes
- Only include projects where there was actual activity that day
- If a day had no dev commits (pure comms/meetings), allocate all non-admin hours to the most relevant project for that day's discussions
- Hours must add up exactly per day and in total, matching the schedule in `context/about.md`
