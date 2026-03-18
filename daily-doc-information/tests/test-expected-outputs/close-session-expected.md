# Expected Output: close-session (T-CL-01)

**Test:** T-CL-01
**Operation:** close-session
**Input fixture:** `test-fixtures/valid-close-session-input.md`

---

## Gate Evaluation

All 6 clean-state criteria must be evaluated before any modification. Expected gate result: **PASS**

| Criterion | Evidence Provided | Expected Result |
|---|---|---|
| CS-01 next_action explicit | "next_action is 'Run PT-R4 integration tests' — single and explicit" | PASS |
| CS-02 blockers declared | "blockers: none" | PASS |
| CS-03 decision recorded | "Decision D1 recorded: 'Test suite created'" | PASS |
| CS-04 validation recorded | "Validation V1 recorded: 'All tests passed'" | PASS |
| CS-05 temp artifacts accounted | "No temporary artifacts created" | PASS |
| CS-06 commit justification stated | "No commits made during this session" | PASS |

---

## Target File Changes

**Path:** `{BASE}/obsidian/CIH/projects/skills/test-project/ai-sessions/2026-03/session-a1b2c3d4-2026-03-17-testagent.md`

### Frontmatter
| Field | Required Value | Notes |
|---|---|---|
| `status` | `complete` | Changed from `in_progress` |
| `closed_at_local` | `2026-03-17 16:00` | Set from timestamp_local |
| `last_updated_at_local` | `2026-03-17 16:00` | Updated |

### Body — Header Block
| Field | Required Value |
|---|---|
| `**Fechamento local real:**` | `2026-03-17 16:00` |
| `**Ultima atualizacao local:**` | `2026-03-17 16:00` |

**Critical (DH-02):** `last_updated_at_local` frontmatter must equal body value.

### Body — Historico de Modificacoes
New final history row at TOP:
```
| 2026-03-17 | [period] | 16:00 | America/Sao_Paulo | TestAgent (testagent) | TEST-MACHINE-001 | Fechamento da sessao. Clean-state gate: PASS. |
```

### Body — Snapshot Atual
| Campo | Required Value |
|---|---|
| `Status geral` | `complete` |
| `Clean-state gate` | `PASS` |

### Body — Handoff Section
Updated with final values from clean_state_evidence.

---

## What Must NOT Change

| Element | Reason |
|---|---|
| `session_id` | Immutable |
| `session_key` / canonical discriminator | Immutable |
| `opened_at_local` | Set at creation, never changed |
| Block content (decisions, validations, history rows before final) | Only the final row is added |

---

## Behavior if ANY Criterion is BLOCKED

If even one CS criterion fails (which does not happen in T-CL-01 but is tested in T-FM-09):
1. Gate result = BLOCKED
2. All 6 criteria returned itemized (DH-10) — no "all good" blanket statement
3. Failing criteria show BLOCKED with explanation
4. **Document is NOT modified** (PB-02 — NO_PARTIAL_CLOSE)
5. FM-09 fires

---

## Required Evidence Block

```
=== EVIDENCE: close-session ===
Operation: close-session
Timestamp: 2026-03-17 16:00
Agent: TestAgent (testagent)
Machine: TEST-MACHINE-001
Target Path: {BASE}/...
Gate Result: PASS
Criteria:
  CS-01 next_action explicit: PASS — next_action is 'Run PT-R4 integration tests'
  CS-02 blockers declared: PASS — blockers: none
  CS-03 decision recorded: PASS — Decision D1: 'Test suite created'
  CS-04 validation recorded: PASS — Validation V1: 'All tests passed'
  CS-05 temp artifacts accounted: PASS — No temporary artifacts created
  CS-06 commit justification stated: PASS — No commits made during this session
Actions Taken:
  - status set to complete: YES
  - closed_at_local set: YES
  - final history row added: YES
  - Snapshot Atual updated: YES
Result: PASS
=== END EVIDENCE ===
```

---

## Hygiene Checks

- [ ] DH-01: Evidence block produced
- [ ] DH-02: frontmatter `last_updated_at_local` = body `Ultima atualizacao local` = `2026-03-17 16:00`
- [ ] DH-03: Final history row is the FIRST data row in table
- [ ] DH-10: Clean-state evidence itemized per criterion (CS-01..CS-06), not blanket statement
