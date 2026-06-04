# Archetype PA — Atlas

A personal assistant for Archetype team members, built on Claude Code.

## What it does

- Orients you on your active projects at the start of each session
- Checks Slack for updates across your project channels (including threads)
- Tracks outstanding items and surfaces what needs attention
- Updates project context as you work, so context is always current
- `/morning` — structured daily briefing
- `/update` — write session learnings back to context files

## Setup

### 1. Clone the repo

```bash
git clone git@github.com:ArchetypeAgency/archetype-ai-pa.git _ai_pa
cd _ai_pa
```

### 2. Set up your personal context

```bash
cp context/about-template.md context/about.md
```

Fill in `context/about.md` with your name, email, Slack channels, and preferences.

### 3. Add your projects

```bash
cp context/projects/_template.md context/projects/[client-name].md
```

Fill in one file per active client or project. Add more files as needed.

### 4. Run it

```bash
claude
```

Atlas reads your context files automatically at session start.

## Personal files stay local

`context/about.md` and your project files are gitignored — they live on your machine and are never committed. This means:

- No branch management
- `git pull` always works cleanly to pick up shared improvements
- Your personal context is yours alone

## Sharing improvements back

If you improve a command, CLAUDE.md, or a template in a way that benefits everyone, open a PR to `main`. Your personal context files won't be staged, so there's no risk of accidentally committing them.
