# DM

Run a Slack sweep across all active projects and deliver the briefing as a Slack DM.

## Steps

1. **Read context files** to know which Slack channels to check:
   - Always read `context/about.md` — it contains the full Slack channel list and the user's Slack member ID
   - Also read any files in `context/projects/` for project-specific context

2. **Check Slack** for each active project:
   - Pull the last 20 messages from each relevant channel or group DM
   - For every message that has replies, read the full thread using `slack_read_thread`

3. **Compose the briefing** in this format:

```
## Atlas Briefing — [date, time]

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

4. **Send the briefing as a Slack DM** to the user using `slack_send_message` with the user's Slack member ID as the channel. The member ID is in `context/about.md`.

5. **Confirm** in the conversation that the DM was sent.

## Notes
- Always check threads before summarising any message
- Keep the briefing tight — one line per item unless something needs explanation
