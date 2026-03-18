# Expected Output: update-next-step (T-NS-01)

**Test:** T-NS-01
**Operation:** update-next-step
**Input fixture:** `test-fixtures/valid-update-next-step-input.md`

---

## Target File

**Path:** `{BASE}/obsidian/CIH/projects/skills/test-new-project/next-step.md`

---

## Required Changes

### Immediate Action Section (REPLACED)
The `Immediate Action` field/section is replaced entirely with:

```
Execute integration tests with real session docs
```

Previous value discarded. This is a **replace**, not append.

### Required Reading (REPLACED — because provided in input)
New list replaces existing:

```
- PROJECT_CONTEXT.md
- status-atual.md
- SKILL.md
```

### Completion Criteria (REPLACED — because provided in input)
New list replaces existing:

```
- All 8 operations tested with valid inputs
- All critical skip conditions verified
- All critical failure modes verified
```

---

## Preservation Rules

| Element | Rule |
|---|---|
| `required_reading` | REPLACED because input provided it |
| `completion_criteria` | REPLACED because input provided it |
| `required_reading` (if absent from input) | PRESERVED — existing content kept |
| `completion_criteria` (if absent from input) | PRESERVED — existing content kept |

---

## What Must NOT Change

| Element | Reason |
|---|---|
| Wikilinks section at bottom | Must be preserved (DH-13) |
| `PROJECT_CONTEXT.md` | Read-only (NW-01) |
| Other project docs | PB-15 — no cross-project writes |

---

## What Must NOT Be Present

| Prohibited Element | Reason |
|---|---|
| `{{...}}` markers | DH-06 |
| `TODO`, `TBD` | PB-04 |
| Old `Immediate Action` value remaining | Section is replaced, not appended |

---

## Required Evidence Block

```
=== EVIDENCE: update-next-step ===
Operation: update-next-step
Timestamp: 2026-03-17 16:00
Agent: TestAgent (testagent)
Machine: TEST-MACHINE-001
Project Path: {BASE}/obsidian/CIH/projects/skills/test-new-project
Immediate Action: Execute integration tests with real session docs
Required Reading Updated: YES
Completion Criteria Updated: YES
Checks:
  - project_path is valid (PROJECT_CONTEXT.md exists): YES
  - Immediate Action is non-empty: YES
  - No placeholders introduced: YES
  - Wikilinks preserved: YES
Result: PASS
=== END EVIDENCE ===
```

---

## Hygiene Checks

- [ ] DH-01: Evidence block produced
- [ ] DH-06: No placeholders introduced
- [ ] DH-13: Wikilinks preserved at bottom of document
- [ ] `Immediate Action` contains exactly the input value (replace, not append)
- [ ] `Required Reading` list has exactly 3 items from input
- [ ] `Completion Criteria` list has exactly 3 items from input
