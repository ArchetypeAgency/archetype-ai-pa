# Check Time

Get the current London time and date.

## Steps

1. Run `TZ="Europe/London" date` via Bash.

2. Parse the output and return:
   - **Greeting** — "Good morning" (before 12:00), "Good afternoon" (12:00–17:59), "Good evening" (18:00+)
   - **Time** — e.g. `6:02pm`
   - **Date** — e.g. `Friday 19 June 2026`

3. Flag anything time-sensitive for today based on project context if available (e.g. phase transitions, deadlines, OOO days).

## Output format

Return a single line, e.g.:

```
Good evening — Friday 19 June 2026, 6:02pm BST
```

Or with a flag:

```
Good evening — Friday 19 June 2026, 6:02pm BST · ⚠️ SMF Phase 0→2 transition tomorrow midnight SGT
```
