# Sweep

Run a Slack sweep and email scan across all active projects and deliver a structured briefing.

## Steps

1. **Read context files** to know which Slack channels and project contacts to check:
   - Always read `context/about.md` — it contains the full Slack channel list
   - Also read any files in `context/projects/` for project-specific context and contacts
   - If no project files exist, use the channels from `context/about.md` only

2. **Check Slack** for each active project:
   - Pull the last 20 messages from each relevant channel or group DM
   - For every message that has replies, read the full thread using `slack_read_thread`
   - Also run a thread scan: `slack_search_public_and_private` with query `@ryan.letbe-holder is:thread`

3. **Scan email** using `outlook_email_search`:
   - Search for unread emails from known project contacts (names and domains from context files — e.g. Matt Pugh, Riz, Cecile Missildine, Remi Fresnel, Steve at QVC, Simon at APAC, Howie, Ash, Stephanie, Clara)
   - Also search for unread emails from `@archetype.co` colleagues
   - Surface any unread emails from outside this list that look potentially important: emails marked high importance, emails from client or agency domains, hosting/service alerts (WPEngine, Render, AWS), anything with project keywords in the subject

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

## Notes
- Always check Slack threads before summarising any message
- For email, filter ruthlessly — only surface things that need Ryan's attention or awareness. Skip newsletters, webinars, automated digests unless actionable
- If a project has no Slack channel recorded, note it and ask the user
- Keep the briefing tight — one line per item unless something needs explanation
