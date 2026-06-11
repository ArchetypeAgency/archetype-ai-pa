# End of Week

Compile a weekly summary of work done, then find the trigger message in the dev team Slack channel and reply to it in-thread. Also syncs BrainPie if the user has it configured.

## Steps

1. **Read context files:**
   - `context/about.md` — Slack handle, member ID, channel list, Brain Pie config
   - All files in `context/projects/` — active projects, Maconomy codes, current focus

2. **Find the trigger message** in the dev team channel (`#ops-development-uk`, ID: `GK79HAEQM`):
   - Read the last 20 messages from the channel using `slack_read_channel`
   - Find the most recent message from the user that contains "what did I do this week" (case-insensitive)
   - Note its `ts` (timestamp) — this is the thread to reply to

3. **Compile this week's git log** across all active repos — run in parallel with step 3b:
   - Run `TZ="Europe/London" date` to get today's date
   - Work out the Monday of the current week
   - For each repo in `~/Sites/` that's relevant to active projects (smf-movewhatmatters, elastic-dashboard, archetype-apac, archetype-uk-non-bedrock, qvc-core-wp-engine, qvc-careers-wp-engine, archetype-ai-pa), run:
     `git -C ~/Sites/[repo] log --format="%ad | %an | %s" --date=short -20 2>/dev/null`
   - Filter for commits from the current week (Mon–today) by the user (author: `ryan-archetype`)
   - Group by project

3b. **Sync BrainPie** (run in parallel with step 3, if Brain Pie is configured):
   - Check `context/about.md` for a **Brain Pie** section with Firebase config
   - If present: run the full `/brainpie` sync — reconcile against project context, write back via Firebase REST API, save `context/brainpie.json`
   - If not present: skip silently
   - End-of-week is the right time to clear completed spokes and add anything new that emerged during the week

4. **Compose a team-friendly weekly update** — concise, factual, written for colleagues (not an internal briefing). Format:

```
*Weekly update — w/e [date]*

*[Project name]* — [1–2 sentence summary of what was done this week. Focus on outcomes and shipped work, not internal detail.]

*[Project name]* — [summary]

[... one entry per active project that had work this week. Skip projects with no activity.]
```

   - Use Slack markdown (`*bold*`, not `**bold**`)
   - Keep each project to 1–2 sentences max
   - Reference specific things shipped (features, fixes, deploys) rather than vague "worked on X"
   - If multiple small things were done on one project, group them into a single coherent sentence

5. **Reply to the trigger message in-thread** using `slack_send_message`:
   - `channel`: `GK79HAEQM`
   - `thread_ts`: the `ts` of the trigger message from step 2 — this is REQUIRED, do not omit it
   - `text`: the composed update
   - Never post as a top-level channel message — always reply in the thread of the trigger message

6. **Confirm** in the conversation that the reply was sent, and show the text that was posted.

## Notes
- If no trigger message is found in the last 20 messages, post the update as a new message to the channel (not a thread reply) and note this in the conversation
- The tone should be team-facing — readable by Andy, Aaliyah, and others in the dev channel
- Week runs Mon–Fri; if today is Thursday, the update covers Mon–Thu
- Don't include Atlas PA / internal tooling commits in the update unless they're significant enough to mention to the team
