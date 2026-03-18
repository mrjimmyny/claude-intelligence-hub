# Expected Output: update-project-status (T-PS-01)

**Test:** T-PS-01
**Operation:** update-project-status
**Input fixture:** `test-fixtures/valid-update-project-status-input.md`
**section:** `completed`

---

## Target File

**Path:** `{BASE}/obsidian/CIH/projects/skills/test-new-project/status-atual.md`

---

## Required Changes

### Completed Section
New bullet point added under the `Completed` (or `## Completed`) section:

```
- Initial project setup completed with all operational docs
```

### Last Update Field
```
Last Update: 2026-03-17
```
Must reflect the current date from `timestamp_local` (DH-12).

### Overall Progress Field
```
Overall Progress: 10% — structure created, implementation pending
```
(Updated because `overall_progress` was provided in input)

---

## Required Content Per Section Logic

| section value | Target | Placement |
|---|---|---|
| `completed` | `Completed` section | New bullet added |
| `in_progress` | `In Progress` section | New bullet added |
| `blocked` | `Blocked` section | New bullet added |

For this test, `completed` → item goes under `Completed` section.

---

## What Must NOT Change

| Element | Reason |
|---|---|
| Items in other sections (In Progress, Blocked) | Only `completed` section receives the new item |
| Wikilinks at bottom of document | Must be preserved (DH-13) |
| `PROJECT_CONTEXT.md` | Read-only (NW-01) — must not be touched |

---

## What Must NOT Be Present

| Prohibited Element | Reason |
|---|---|
| `{{...}}` markers | DH-06 |
| `TODO`, `TBD` | PB-04 |
| `Last Update: [old date]` | DH-12 requires current date |

---

## Invalid section Values

If section = anything other than `completed`, `in_progress`, `blocked`:
- FM-16 fires (PROJECT_STATUS_SECTION_INVALID)
- Response includes the received value and lists valid options
- Document not modified

---

## Required Evidence Block

```
=== EVIDENCE: update-project-status ===
Operation: update-project-status
Timestamp: 2026-03-17 15:00
Agent: TestAgent (testagent)
Machine: TEST-MACHINE-001
Project Path: {BASE}/obsidian/CIH/projects/skills/test-new-project
Section: completed
Content: Initial project setup completed with all operational docs
Checks:
  - project_path is valid (PROJECT_CONTEXT.md exists): YES
  - Section is valid: YES
  - Item added to correct section: YES
  - Last Update is current: YES
  - No placeholders introduced: YES
  - Wikilinks preserved: YES
Result: PASS
=== END EVIDENCE ===
```

---

## Hygiene Checks

- [ ] DH-01: Evidence block produced
- [ ] DH-06: No placeholders introduced
- [ ] DH-12: `Last Update` = `2026-03-17` (current date)
- [ ] DH-13: Wikilinks preserved at bottom of document
