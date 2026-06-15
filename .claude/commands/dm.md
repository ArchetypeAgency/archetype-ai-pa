# DM

Run a Slack sweep and email scan across all active projects and deliver the briefing as a Slack DM.

> **Note:** `dm.md` and `scan.md` share the same core logic (steps 1–3). If you update the scanning or email steps here, mirror the change in `scan.md`.

## Steps

1. **Read context files** to know which Slack channels and project contacts to check:
   - Always read `context/about.md` — it contains the full Slack channel list and the user's Slack member ID
   - Also read any files in `context/projects/` for project-specific context and contacts

2. **Check Slack** for each active project:
   - Pull the last 20 messages from each relevant channel or group DM
   - For every message that has replies, read the full thread using `slack_read_thread`
   - Also run a thread scan: `slack_search_public_and_private` with query `[SLACK HANDLE] is:thread` (handle from `context/about.md`)

3. **Scan email** using `outlook_email_search`:
   - Search for unread emails from known project contacts — derive the contact list at runtime from the `## Key people` and `## Key contacts` sections of each `context/projects/` file
   - Also search for unread emails from `@archetype.co` colleagues
   - Surface any unread emails from outside this list that look potentially important: emails marked high importance, emails from client or agency domains, hosting/service alerts (WPEngine, Render, AWS), anything with project keywords in the subject

4. **Compose the briefing** in this format:

```
## Atlas Briefing — [date, time]

### 🔴 Needs action
[Items requiring a response or decision from the user today — Slack and email combined]

### 🟡 In progress / waiting
[Items where work is underway or waiting on others]

### 🟢 No change
[Projects with no new activity]

### 📧 Email
[Actionable emails from project contacts or flagged as potentially important. One line each — sender, subject, why it matters. Skip newsletters and automated notifications unless they contain something actionable.]

---
### Open items across all projects
[Consolidated list of outstanding tasks from context files]
```

5. **Send the briefing as a Slack DM** to the user using `slack_send_message` with the user's Slack member ID as the channel. The member ID is in `context/about.md`.

6. **Confirm** in the conversation that the DM was sent.

## Notes
- Always check Slack threads before summarising any message
- For email, filter ruthlessly — only surface things that need the user's attention or awareness. Skip newsletters, webinars, automated digests unless actionable
- Keep the briefing tight — one line per item unless something needs explanation
