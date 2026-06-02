# Archetype PA

A personal assistant for Archetype team members, built on Claude Code.

## What it does

- Orients you on your active projects at the start of each session
- Checks Slack for updates across your project channels (including threads)
- Tracks outstanding items and surfaces what needs attention
- Updates project context as you work, so context is always current
- `/morning` — structured daily briefing
- `/update` — write session learnings back to context files

## Setup

### 1. Create your personal branch

```bash
git checkout -b [your-name]
```

### 2. Set up your personal context

```bash
cp context/about-template.md context/about.md
```

Fill in `context/about.md` with your role, Slack channels, and preferences.

### 3. Add your projects

```bash
cp context/projects/_template.md context/projects/[client-name].md
```

Fill in one file per active client or project.

### 4. Run it

```bash
claude
```

The PA reads your context files automatically at session start.

## Branch structure

- `main` — shared base: instructions, commands, templates. Don't put personal info here.
- `[your-name]` — your personal branch: `context/about.md` + your project files

## Updating shared improvements

If you improve the commands or CLAUDE.md in a way that benefits everyone, open a PR to `main`.
