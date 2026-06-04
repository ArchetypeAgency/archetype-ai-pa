# Sweep

Run a Slack sweep across all active projects and deliver a structured briefing.

## Steps

1. **Read context files** to know which Slack channels to check:
   - Always read `context/about.md` — it contains the full Slack channel list
   - Also read any files in `context/projects/` for project-specific context
   - If no project files exist, use the channels from `context/about.md` only

2. **Check Slack** for each active project:
   - Pull the last 20 messages from each relevant channel or group DM
   - For every message that has replies, read the full thread using `slack_read_thread`
   - Note the timestamp of the most recent activity

3. **Output a structured briefing** in this format:

```
## Atlas Briefing — [date]

### 🔴 Needs action
[Items requiring a response or decision from the user today]

### 🟡 In progress / waiting
[Items where work is underway or waiting on others]

### 🟢 No change
[Projects with no new activity]

---
### Open items across all projects
[Consolidated list of outstanding tasks from context files]
```

4. **Offer to update context files** if any project status has changed based on what you found in Slack.

5. **Flag any context files that look stale** (last-updated date more than 3 days ago relative to today's date).

## Notes
- Always check threads — top-level messages without threads often miss the most recent replies
- If a project has no Slack channel recorded, note it and ask the user
- Keep the briefing tight — one line per item unless something needs explanation
