# Update Context

Save session learnings back to the relevant project context files.

## Steps

0. Run `/checktime` to get the current London time and date.

1. **Review what changed this session** — look back at what was discussed, decided, built, or learned.

2. **For each affected project**, update the context file in `context/projects/`:
   - Update the **Status** line if it changed
   - Tick off completed outstanding items
   - Add new outstanding items that emerged
   - Update the **Current focus** section
   - Add a **Notes** entry if a decision or constraint was established that isn't obvious from the code

3. **Add a last-updated date** to any file you modify, in the format:
   `**Last updated:** YYYY-MM-DD`

4. **Check `context/about.md`** — if anything about the user's own setup changed this session (new Slack channels, preference update, new tool, changed working hours), update `context/about.md` too.

5. **Report back** — list which files were updated and what changed in each.

## What warrants an update
- A task was completed ✅
- A new task or blocker emerged
- A decision was made (e.g. scope change, tech choice, deadline set)
- A Slack conversation changed the project status
- A piece of context that was "unknown" is now known

## What doesn't need an update
- Ephemeral details that won't matter next session
- Things already captured in git history or the code itself
