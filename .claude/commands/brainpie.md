# BrainPie

Sync `context/brainpie.json` with the live brainpie.app via Firebase RTDB, then report what changed.

## How it works

Atlas is the liaison between the user and BrainPie. The pie is a **shared, live data source** — the user edits it directly in the app at any time. Always treat Firebase as the source of truth. Never assume that a spoke absent from the pie needs to be re-added; if it's gone, the user removed it intentionally.

Use a **pull, then push** approach:
1. Read the live pie from Firebase first
2. Apply only additive changes (new tasks not yet tracked) and removals (tasks marked ✅ in context files)
3. Keep context files in sync with what you observe in the pie — if spokes have been removed or added by the user, update the context files to reflect that

Firebase config is in `context/about.md` under **Brain Pie**.

## Steps

### 1. Read pie from Firebase

Read DB URL, project ID, secret, and UID from `context/about.md` under **Brain Pie**, then:

```bash
# Get active pieId from meta
curl -s "${DB}/brainpie/${PROJECT}/users/${UID}/meta.json?auth=${SECRET}"

# Get pie (use activePieId from meta — no hardcoded ID needed)
curl -s "${DB}/brainpie/${PROJECT}/users/${UID}/pies/<activePieId>.json?auth=${SECRET}"
```

### 2. Reconcile against project context

Compare the live pie against current project context. Apply these rules:
- **Remove** spokes for tasks marked ✅ in context files — but only if the spoke is still in the pie
- **Add** spokes only for tasks that are genuinely new (appeared in context since the last sync) and not already present in the pie
- **Never re-add** spokes that are absent from the pie — absence means the user deleted them
- **Preserve** all user-set percentages, colors, IDs, and scheduled dates exactly as they are
- **If** unsure whether something is new or a user deletion, ask before adding

New spoke structure:
```json
{
  "text": "Task description",
  "type": "static",
  "children": [],
  "scheduled": null,
  "metadata": { "calendarEventId": null, "recurrence": null }
}
```

New IDs: generate a UUID string (e.g. via `python3 -c "import uuid; print(uuid.uuid4())"` or similar).

### 3. Write updated pie to Firebase

Set `lastModified` to current epoch ms before writing:

```bash
# Write pie (lastModified must be updated to current epoch ms)
curl -s -X PUT "${DB}/brainpie/${PROJECT}/users/${UID}/pies/<pieId>.json?auth=${SECRET}" \
  -H "Content-Type: application/json" \
  -d '<updated pie JSON with new lastModified>'
```

### 4. Save local cache

Write the updated pie to `context/brainpie.json`.

### 5. Report

List what was added, removed, or updated — one line each.

## Notes
- Always read before writing — never reconstruct from scratch
- BrainPie is a live data source; the user updates it directly. Pull first, always.
- A spoke missing from the pie means the user deleted it — do not re-add it
- `lastModified` must be updated on every write (epoch ms) so the app knows the data is fresh
- Meta only needs updating if pieIds/pieNames change — most syncs only touch the pie blob
