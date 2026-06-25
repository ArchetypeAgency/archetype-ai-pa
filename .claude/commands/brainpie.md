# BrainPie

## How BrainPie stores data

BrainPie has two storage backends. The one in use is set per-device in the app's Settings → Storage.

**Local mode** (merged Jun 2026 — `LocalFileAdapter`, `StorageAdapter v2`)
BrainPie reads and writes a JSON file directly on disk via the browser's File System Access API. The user grants access to a file once; after that the app keeps it open. `context/brainpie.json` in this repo is that file. This is the mode to use at work — no Firebase account needed, data never leaves the machine.

**Cloud mode (Firebase)**
BrainPie syncs to a Firebase Realtime Database. The user must have a Firebase project set up and credentials stored in `context/about.md`.

## How Atlas maps to these

Check `context/about.md` → Brain Pie → **Sync mode** before doing anything:

- `Sync mode: file` — BrainPie is in **local mode**. Atlas reads/writes `context/brainpie.json` directly. The file is the source of truth. No Firebase calls.
- `Sync mode: firebase` — BrainPie is in **cloud mode**. Atlas reads/writes via the Firebase REST API and keeps `context/brainpie.json` as a local cache.

**Setting up a new work instance:** set `Sync mode: file` in `context/about.md`, then open BrainPie, go to Settings → Storage → Local file, and point it at `context/brainpie.json` in this repo. Both sides now read/write the same file — no push step needed.

---

## File mode

Read and update `context/brainpie.json` — the file BrainPie is watching. No Firebase calls needed. Report what changed.

Atlas reads `context/brainpie.json`, makes any changes needed, updates `lastModified`, and writes it back. BrainPie picks up the changes directly from the file because it holds the file handle open.

## Steps

### 1. Read the file

```python
import json
with open('context/brainpie.json') as f:
    data = json.load(f)

meta = data['meta']
active_pie_id = meta['activePieId']
pie = data['pies'][active_pie_id]
priorities = data.get('priorities', {}).get(active_pie_id, [])
```

### 2. Scan for what to add — be proactive

Before reconciling, actively source new material. Don't only look at what's already in the pie:

**Scan context files** — read all `context/projects/` files and pull out every outstanding item, recent change, and flagged risk that isn't already represented.

**Scan Slack and email** — if a `/scan` or `/sync` has run this session (or you have recent Slack/email output in context), mine it for:
- Anything mentioned as urgent, overdue, or blocked
- Any concrete future dates: calls, launches, transitions, deadlines, renewals, expiries
- Any red-dot or warning items that should be visible on the pie

**Look forward for schedule pills** — schedule pills are the most powerful visual cue in BrainPie. For every date-anchored item you find, create a `single` type sub-item with `scheduled.date` set. Look for:
- Upcoming calls and reviews with known dates
- Phase transitions or launch windows
- Token/secret/subscription expiry dates
- OOO windows (yours and key contacts)
- Rota changes or shift anomalies
- Monthly recurring admin (invoices, reports)

**Add new slices when a theme isn't represented** — if a whole area of work (e.g. Security, a new client, a recurring admin theme) has no slice, create one. New categories should get a `categoryPercentageOverrides` entry sized to reflect their real weight.

**Don't wait to be asked** — if something belongs in BrainPie, add it. The goal is that the pie reflects everything real, not just what was last manually updated.

### 3. Reconcile

Make any changes Atlas needs to make — add spokes, update dates, remove completed items. 

- **Preserve** user-set percentages, colors, IDs, and scheduled dates
- **Check** the relevant project file's `## Recent changes` log — if a spoke was recently deleted by Atlas, don't re-add it
- **Ask** before making any change you're unsure about

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

Spoke types:
- `static` — ongoing/standing task, no date, no children (default)
- `single` — one-off event with a date; populate `scheduled`
- `repeating` — recurring event; populate `metadata.recurrence` + `scheduled` for next occurrence
- `list` — task with sub-items; populate `children` array (`{ text, completed, scheduled }`)

New IDs: generate a UUID string (e.g. via `python3 -c "import uuid; print(uuid.uuid4())"` or similar).

### 3. Write back

Update `lastModified` to current epoch ms so BrainPie knows the data is fresh:

```python
import time, json

pie['lastModified'] = int(time.time() * 1000)
data['pies'][active_pie_id] = pie
data['priorities'][active_pie_id] = priorities  # include any priority changes

with open('context/brainpie.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

### 4. Log changes to context files

For each project file affected, append to its `## Recent changes` section:
```
- YYYY-MM-DD Added: "spoke text" to Slice name
- YYYY-MM-DD Deleted: "spoke text" from Slice name
```

### 5. Report

List what was added, removed, or updated — one line each.

## Priority list

Priorities live at `data['priorities'][pieId]` in the same file:

```json
[
  { "categoryId": "...", "itemId": "...", "type": "slice" },
  { "categoryId": "...", "itemId": "...", "type": "spoke", "spokeIndex": 0 }
]
```

- `type: "slice"` — the whole slice is prioritised; omit `spokeIndex`
- `type: "spoke"` — a specific spoke; `spokeIndex` is its position in `subItems` (0-based)
- Order of the array = display order in the priorities panel
- ⚠️ `spokeIndex` is positional — if spokes are reordered in the pie, the index can drift

## Notes
- In **file mode**: `context/brainpie.json` is the source of truth — what's in the file is what BrainPie shows. No push step needed, but **BrainPie requires a browser reload to pick up Atlas's writes** — the File System Access API does not watch for external changes.
- In **firebase mode**: `context/brainpie.json` is a local cache. Firebase is the source of truth. Always write back to the cache after a Firebase read.
- Always read before writing — never reconstruct from scratch
- `lastModified` must be updated on every write (epoch ms) so BrainPie knows the data is fresh
- Meta only needs updating if pieIds/pieNames change — most syncs only touch the pie blob

## Firebase mode

When `Sync mode: firebase` in `context/about.md`, Atlas reads/writes via the Firebase REST API.
`context/brainpie.json` is the local cache — still update it after each Firebase read so the file stays current.
Firebase config lives in `context/about.md` under **Brain Pie**.

```bash
DB="https://brain-pie-shared-default-rtdb.europe-west1.firebasedatabase.app"
PROJ="brain-pie-shared"
FUID="oCwYCeq0cAZxS1Erfahfg1qvNur1"
SECRET="VagCOAeIvvE4KgkhjPJEhYONOg1wWG7bKrvlts0O"
PIE_ID="pie-1773763896169"

# ⚠️ Use FUID not UID — UID is a reserved shell variable and will cause "operation not permitted"

# Read meta
curl -s "${DB}/brainpie/${PROJ}/users/${FUID}/meta.json?auth=${SECRET}"

# Read pie
curl -s "${DB}/brainpie/${PROJ}/users/${FUID}/pies/${PIE_ID}.json?auth=${SECRET}"

# Write pie (update lastModified to current epoch ms first)
curl -s -X PUT "${DB}/brainpie/${PROJ}/users/${FUID}/pies/${PIE_ID}.json?auth=${SECRET}" \
  -H "Content-Type: application/json" \
  -d '<updated pie JSON>'

# Read priorities
curl -s "${DB}/brainpie/${PROJ}/users/${FUID}/priorities/${PIE_ID}.json?auth=${SECRET}"

# Write priorities
curl -s -X PUT "${DB}/brainpie/${PROJ}/users/${FUID}/priorities/${PIE_ID}.json?auth=${SECRET}" \
  -H "Content-Type: application/json" \
  -d '<priority array JSON>'
```

In Firebase mode, `context/brainpie.json` is the local cache (not the source of truth).
After any Firebase read, write the result back to `context/brainpie.json` so it stays current.
To switch back to file mode: set `Sync mode: file` in `context/about.md`.
