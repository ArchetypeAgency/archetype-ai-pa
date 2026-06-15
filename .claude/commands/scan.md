# Scan

Run a Slack and email scan across all active projects and deliver a structured briefing.

## Steps

1. **Read context files** to know which Slack channels and project contacts to check:
   - Always read `context/about.md` — it contains the full Slack channel list, Slack handle, and member ID
   - Also read any files in `context/projects/` for project-specific context and contacts
   - If no project files exist, use the channels from `context/about.md` only

2. **Check Slack** for each active project:
   - Pull the last 20 messages from each relevant channel or group DM
   - For every message that has replies, read the full thread using `slack_read_thread`
   - Also run a thread scan: `slack_search_public_and_private` with query `[SLACK HANDLE] is:thread` (handle from `context/about.md`)

3. **Scan email** using `outlook_email_search`:
   - Search for unread emails from known project contacts (names and domains from context files)
   - Also search for unread emails from `@archetype.co` colleagues
   - Surface any unread emails from outside this list that look potentially important: emails marked high importance, emails from client or agency domains, hosting/service alerts (WPEngine, Render, AWS), anything with project keywords in the subject
   - If `outlook_email_search` is unavailable (M365 not connected), skip this step entirely. In the briefing, include a one-line note under `### 📧 Email`: "Email scanning unavailable — connect Microsoft 365 via `/mcp` to enable."

4. **Output a structured briefing** in this format:

```
## Atlas Briefing — [date]

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

5. **Offer to update context files** if any project status has changed based on what you found.

6. **Flag any context files that look stale** (last-updated date more than 3 days ago relative to today's date).

7. **BrainPie** — check `context/about.md` for a Brain Pie section with Firebase config.
   - If it exists: skip (BrainPie already syncs at session start via `/brainpie`).
   - If it doesn't exist: offer at the end of the briefing:

   > "Want me to set up BrainPie for your projects? I can build a pie from your open tasks and walk you through connecting it to Firebase so it stays in sync. Takes about 5 minutes — or skip it for now."

   If the user wants to proceed, refer them to the `/brainpie` setup flow.

## Notes
- Always check Slack threads before summarising any message
- For email, filter ruthlessly — only surface things that need the user's attention or awareness. Skip newsletters, webinars, automated digests unless actionable
- If a project has no Slack channel recorded, note it and ask the user
- Keep the briefing tight — one line per item unless something needs explanation
