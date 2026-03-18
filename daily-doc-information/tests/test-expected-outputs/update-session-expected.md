# Expected Output: update-session (T-US-01)

**Test:** T-US-01
**Operation:** update-session
**Input fixture:** `test-fixtures/valid-update-session-input.md`
**update_type:** `history`

---

## Target File

**Path:** `{BASE}/obsidian/CIH/projects/skills/test-project/ai-sessions/2026-03/session-a1b2c3d4-2026-03-17-testagent.md`

---

## Required Changes

### Frontmatter
| Field | Required Value | Notes |
|---|---|---|
| `last_updated_at_local` | `2026-03-17 15:00` | Updated from 14:30 to 15:00 |
| `status` | `in_progress` | Unchanged — doc is still open |
| `closed_at_local` | `pending` | Unchanged |

### Body — Header Block
| Field | Required Value |
|---|---|
| `**Ultima atualizacao local:**` | `2026-03-17 15:00` |

**Critical (DH-02):** `last_updated_at_local` in frontmatter MUST equal `Ultima atualizacao local` in body. Both must be `2026-03-17 15:00`.

### Body — Historico de Modificacoes (DH-03)
New row must be **prepended at the TOP** of the table (newest first rule).

**New row (first data row in table):**
```
| 2026-03-17 | [period] | 15:00 | America/Sao_Paulo | TestAgent (testagent) | TEST-MACHINE-001 | Test validation run completed. All checks passed. |
```

**Ordering after update:**
1. `2026-03-17 | ... | 15:00 | ... | Test validation run completed. All checks passed.` ← NEW, at TOP
2. `2026-03-17 | ... | 14:30 | ... | Criacao do session doc.` ← original, pushed down

---

## What Must NOT Change

| Element | Reason |
|---|---|
| `status` | Remains `in_progress` |
| `session_id` | Immutable |
| `session_key` / canonical discriminator | Immutable |
| `opened_at_local` | Set at creation, never changed |
| `closed_at_local` | Remains `pending` |
| All block content (Decisoes, Validacoes, Snapshot Atual) | update_type=history only touches the history table |

---

## What Must NOT Be Introduced

| Prohibited Element | Reason |
|---|---|
| Any `{{...}}` marker | DH-06 — no placeholders in output |
| Stale paths (paths without `skills/`) | DH-05 |
| Row appended at BOTTOM of history table | DH-03 — must prepend |

---

## Required Evidence Block

```
=== EVIDENCE: update-session ===
Operation: update-session
Timestamp: 2026-03-17 15:00
Agent: TestAgent (testagent)
Machine: TEST-MACHINE-001
Target Path: {BASE}/obsidian/CIH/projects/skills/test-project/ai-sessions/2026-03/session-a1b2c3d4-2026-03-17-testagent.md
Update Type: history
Checks:
  - Target exists: YES
  - Target status is open: YES
  - Content added to correct section: YES
  - last_updated_at_local frontmatter matches body: YES
  - No stale paths introduced: YES
  - No placeholders introduced: YES
Result: PASS
=== END EVIDENCE ===
```

---

## Hygiene Checks

- [ ] DH-01: Evidence block produced
- [ ] DH-02: frontmatter `last_updated_at_local` = body `Ultima atualizacao local` = `2026-03-17 15:00`
- [ ] DH-03: New history row is the FIRST data row in the table
- [ ] DH-05: No stale paths introduced
- [ ] DH-06: No placeholders introduced
