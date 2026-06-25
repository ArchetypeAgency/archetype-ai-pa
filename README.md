# Archetype PA — Atlas

A personal assistant for Archetype team members, built on Claude Code.

## What it does

- Runs a guided setup on first launch — no manual config needed
- Orients you on your active projects at the start of each session
- Checks Slack for updates across your project channels (including threads)
- Tracks outstanding items and surfaces what needs attention
- Updates project context as you work, so context is always current
- Sends a scheduled briefing to your Slack DM twice a day

## Setup

```bash
git clone git@github.com:ArchetypeAgency/archetype-ai-pa.git
cd archetype-ai-pa
claude
```

That's it. Atlas will introduce itself and walk you through the rest.

## What setup configures

- Your profile (name, email, role, tools)
- Your Slack channels to monitor
- Which folders Atlas can access on your machine
- Your daily Atlas Briefing triggers (8:50am and 12:50pm, Mon–Fri)
- Your first project file (optional)

## Folder access

Atlas can access the folder this repo lives in and everything alongside it by default. For example, if you clone into `~/Sites/archetype-ai-pa`, Atlas can read other repos in `~/Sites/`.

If you're not a developer, or keep your work in a different place (e.g. `~/Documents`, `~/Uploads`, a shared drive), setup will ask you which folders to add. You can also edit `.claude/settings.json` at any time:

```json
{
  "additionalDirectories": ["..", "/Users/yourname/Documents/client-work"]
}
```

## Personal files stay local

`context/about.md` and your project files are gitignored — they live on your machine and are never committed. This means:

- No branch management
- `git pull` always works cleanly to pick up shared improvements
- Your personal context is yours alone

## Quick mode

If you want to open a session without the full startup briefing (no project reads, no Slack scan, no summary), set `ATLAS_QUICK=1` before launching:

```bash
ATLAS_QUICK=1 claude
```

Atlas will output the time/greeting and stop, waiting for your first instruction. Useful when you just need to run a quick task.

## Sharing improvements back

If you improve a command, CLAUDE.md, or a template in a way that benefits everyone, open a PR to `main`. Your personal context files won't be staged, so there's no risk of committing them.
