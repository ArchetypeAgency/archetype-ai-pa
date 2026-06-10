# BrainPie

Sync `context/brainpie.json` with the live brainpie.app via Firebase RTDB, then report what changed.

## How it works

Atlas reads the pie from Firebase, reconciles it against current project context, and writes it back. No Playwright or browser needed.

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

Use the project context already loaded at session start. Apply these rules:
- **Remove** spokes for tasks marked ✅ in context files
- **Add** spokes for outstanding tasks not yet in the pie
- **Add/remove** slices and categories as projects change
- **Preserve** user-set percentages, colors, IDs, and scheduled dates
- **If** unsure about a slice/spoke, ask before making any change

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
- `lastModified` must be updated on every write (epoch ms) so the app knows the data is fresh
- Meta only needs updating if pieIds/pieNames change — most syncs only touch the pie blob
