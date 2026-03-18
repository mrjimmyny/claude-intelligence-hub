# Expected Output: register-decision (T-RD-01)

**Test:** T-RD-01
**Operation:** register-decision
**Input fixture:** `test-fixtures/valid-register-decision-input.md`

---

## Target File

**Path:** `{BASE}/obsidian/CIH/projects/skills/test-new-project/decisoes.md`

---

## Required Changes

### New Entry at TOP (after `# Decision Log` header, before any existing entries)

```markdown
## 2026-03-17

Decision:
Test suite will use specification-based testing, not runtime execution

Reason:
The skill is instruction-based (markdown), not code — runtime tests are not applicable

Impact:
All test cases verify contract completeness and correctness, not execution
```

---

## Format Requirements (DH-11)

Every decision entry MUST have all three fields. Missing any field = hygiene violation.

| Field | Required | Content |
|---|---|---|
| `## YYYY-MM-DD` header | Yes | `## 2026-03-17` |
| `Decision:` line | Yes | From `decision` input |
| `Reason:` line | Yes | From `reason` input |
| `Impact:` line | Yes | From `impact` input |

---

## Ordering Rule

New entries go at the **TOP** of the log, AFTER the `# Decision Log` header and BEFORE any existing entries (newest first).

**Before:**
```
# Decision Log

[older entries...]
```

**After:**
```
# Decision Log

## 2026-03-17

Decision: Test suite will use specification-based testing...
Reason: The skill is instruction-based...
Impact: All test cases verify...

[older entries unchanged below...]
```

---

## What Must NOT Change

| Element | Reason |
|---|---|
| Existing entries | Only new entry added at top; existing entries preserved below |
| Wikilinks section at bottom | Must be preserved (DH-13) |
| `PROJECT_CONTEXT.md` | Read-only (NW-01) |
| `status-atual.md` | Not touched by register-decision |

---

## What Must NOT Be Present

| Prohibited Element | Reason |
|---|---|
| `{{...}}` markers | DH-06 |
| Entry missing Decision, Reason, or Impact field | DH-11 |
| New entry at BOTTOM of log | Must be at TOP |
| Decision fabricated by agent | PB-13 (NO_PROJECT_DECISION_FABRICATION) |

---

## Required Evidence Block

```
=== EVIDENCE: register-decision ===
Operation: register-decision
Timestamp: 2026-03-17 15:30
Agent: TestAgent (testagent)
Machine: TEST-MACHINE-001
Project Path: {BASE}/obsidian/CIH/projects/skills/test-new-project
Decision Date: 2026-03-17
Checks:
  - project_path is valid (PROJECT_CONTEXT.md exists): YES
  - All three fields non-empty (Decision/Reason/Impact): YES
  - Entry added at TOP (before existing entries): YES
  - No placeholders introduced: YES
  - Wikilinks preserved: YES
Result: PASS
=== END EVIDENCE ===
```

---

## Hygiene Checks

- [ ] DH-01: Evidence block produced
- [ ] DH-06: No placeholders introduced
- [ ] DH-11: Entry has all three fields (Decision, Reason, Impact)
- [ ] DH-13: Wikilinks preserved at bottom of document
- [ ] Entry placed at TOP of log (before any existing entries)
