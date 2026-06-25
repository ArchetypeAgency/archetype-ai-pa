# Brief

Turn client feedback into a structured implementation brief ready for Dex (or Artor) to execute.

## Usage

```
/brief <source> [<source2> <source3> ...]
```

Where each `<source>` is one of:
- A **Slack thread URL** (e.g. `https://archetype.slack.com/archives/C.../p...`)
- A **Google Drive doc URL**
- A **Figma file or frame URL**
- **Pasted notes** — just type or paste them after `/brief`

Multiple sources are supported — pass as many URLs or blocks of notes as needed. All sources are fetched, then merged into a single brief. Each piece of feedback is attributed to its source.

## Steps

### 0. Check time

Run `/checktime` to get the current London time and date.

### 1. Identify the source types

For each argument:
- URL containing `slack.com` → fetch via Slack MCP
- URL containing `docs.google.com` or `drive.google.com` → fetch via Google Drive MCP
- URL containing `figma.com` → fetch via Figma MCP
- Anything else → treat as raw notes (use directly)

### 2. Fetch all content in parallel

**Slack thread URL:**
Parse the channel ID and thread timestamp from the URL. Format: `/archives/<channelId>/p<timestamp>` — the timestamp has an implied decimal 6 places from the right (e.g. `p1234567890123456` → `1234567890.123456`).

```
slack_read_thread(channel: <channelId>, thread_ts: <timestamp>)
```

If the URL is a channel message (no thread), read just that message. If it links to a channel with no specific message, read the last 20 messages with `slack_read_channel`.

**Google Drive URL:**
Extract the file ID from the URL and read it:
```
google_drive read_file_content(file_id: <id>)
```

**Figma URL:**
```
figma get_design_context(url: <url>)
```

### 3. Identify the project

Read the relevant `context/projects/` file. Match the project based on:
- Keywords in the fetched content (client names, repo names, feature names)
- The Slack channel ID if it came from a thread (cross-reference channels listed in `context/about.md`)
- The Figma or Drive file if it matches a URL stored in a project file

If multiple sources point to the same project, proceed. If sources span different projects, ask the user whether to write one combined brief or separate ones before continuing. If the project is unclear, ask.

If the project is identified from raw notes (no URL to cross-reference), state the assumed project explicitly — e.g. "This looks like SMF — is that right?" — before writing the brief. Do not assume silently.

### 4. Determine the recipient

Decide who the brief is for:
- **Artor** — if the feedback is design-related (visual issues, layout, component behaviour, Figma references, fidelity problems). Artor will review, issue precise instructions, and spawn Dex.
- **Dex** — if the task is clearly a code change with no design ambiguity (a bug fix, a content update, a config change, a well-specified feature).

When in doubt, default to Artor — he will brief Dex as needed.

### 5. Write the brief

Create `context/briefs/<project-slug>-<YYYY-MM-DD>.md` using this format:

```markdown
# [Artor/Dex] Brief — <short description>
**Date:** <today's date>
**From:** Jimi (PM)
**To:** <Artor (design director) → Dex (senior dev) | Dex (senior dev)>

---

## Context

<Project name and one-sentence description. Repo path. Any phase, environment, or branch context that matters. Keep to 3–5 lines.>

---

## Feedback received

<Attribute each piece of feedback precisely: who said it, where (Slack/email/doc), what they said. Quote directly where possible. Group by person. Be specific — vague feedback should be flagged as needing clarification rather than assumed.>

---

## Instructions to <Artor/Dex>

<Numbered list. Each item should be specific and actionable. Include file paths where known. If spawning Artor: ask him to (1) explore the codebase, (2) diagnose precisely, (3) issue Dex instructions, (4) spawn Dex, (5) report back. If spawning Dex directly: each item is a specific code change.>

---

## Outcome

<Leave blank — to be filled after the work is done.>
```

### 6. Present and confirm

Show the brief to the user. Ask:
> "Ready to spawn [Artor/Dex] with this brief?"

If yes: spawn the appropriate agent via the Agent tool, passing the full brief as context. The agent prompt must include the full persona description verbatim from CLAUDE.md (copy the entire named section — e.g. "Artor — design director..." or "Dex — senior developer..." — and paste it at the top of the prompt). Agents start with zero context; referencing the name alone is not enough. After the persona block, state the brief in full and ask them to get to work.

If no, or if the user wants to edit: make any requested changes first, then ask again.

## Notes

- Always attribute feedback to specific people — "client said" is not enough
- If sources span multiple unrelated projects, ask before combining into one brief or splitting
- If a single source contains multiple unrelated requests, ask whether to combine or split
- Briefs are saved to `context/briefs/` — this folder is gitignored (personal context)
- The project slug should match the folder/filename convention already in use (e.g. `smf`, `elastic`, `apac`, `qvc`)
- If the source is ambiguous or lacks enough detail to write specific instructions, flag what's missing rather than guessing
