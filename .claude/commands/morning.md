# Morning Briefing

Run a structured morning briefing across all active projects.

## Steps

1. **Read all context files** in `context/projects/` to know which projects are active and which Slack channels/DMs to check.

2. **Check Slack** for each active project:
   - Pull the last 5 messages from each relevant channel or group DM
   - For every message that has replies, read the full thread using `slack_read_thread`
   - Note the timestamp of the most recent activity

3. **Output a structured briefing** in this format:

```
## Morning Briefing — [date]

### 🔴 Needs action
[Items requiring a response or decision from Ryan today]

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
- If a project has no Slack channel recorded, note it and ask Ryan
- Keep the briefing tight — one line per item unless something needs explanation
