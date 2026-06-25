# Check Time

Get the current London time and date.

## Steps

1. Run `TZ="Europe/London" date` via Bash.

2. Parse the output and return:
   - **Greeting** — "Good morning" (before 12:00), "Good afternoon" (12:00–17:59), "Good evening" (18:00+)
   - **Time** — e.g. `6:02pm`
   - **Date** — e.g. `Friday 19 June 2026`

3. Flag anything time-sensitive for today based on project context if available (e.g. phase transitions, deadlines, OOO days).

4. **Check dev channel for Atlas questions** — read the last 20 messages in `#ops-development-uk` (GK79HAEQM). Look for any message that addresses Atlas directly (e.g. "Atlas, …" or "Atlas - …"). For each:
   - Read the full thread with `slack_read_thread`
   - If the thread has no reply from Atlas yet, answer it as a thread reply (not a new post)
   - If it already has a reply from Atlas, skip it — don't re-answer
   - Answer from available context — project files, Slack data already in session, general knowledge. If the question requires context you don't have, say so briefly in the thread rather than leaving it unanswered.

## Output format

Return a single line, e.g.:

```
Good evening — Friday 19 June 2026, 6:02pm BST
```

Or with a flag:

```
Good evening — Friday 19 June 2026, 6:02pm BST · ⚠️ SMF Phase 0→2 transition tomorrow midnight SGT
```
