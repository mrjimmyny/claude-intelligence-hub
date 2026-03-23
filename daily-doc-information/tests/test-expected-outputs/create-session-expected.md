# Expected Output: create-session (T-CS-01)

**Test:** T-CS-01
**Operation:** create-session
**Input fixture:** `test-fixtures/valid-create-session-input.md`

---

## Output File

**Path:** `{BASE}/obsidian/CIH/projects/skills/test-project/ai-sessions/2026-03/session-a1b2c3d4-2026-03-17-testagent.md`

**Filename pattern check:** `session-[session_id_short]-[YYYY-MM-DD]-[agent_slug].md`
- session_id_short = `a1b2c3d4` ✓
- date = `2026-03-17` ✓
- agent_slug = `testagent` ✓

---

## Required Frontmatter Fields

All of the following must be present and non-empty:

| Field | Required Value | Notes |
|---|---|---|
| `title` | "Session Log - TestAgent - 2026-03-17" | Exact pattern |
| `date` | `2026-03-17` | From timestamp_local |
| `session_id` | `a1b2c3d4-e5f6-7890-abcd-ef1234567890` | Full UUID from input |
| `session_id_short` | `a1b2c3d4` | First 8 chars of session_id |
| `session_key` | `a1b2c3d4-TEST-MACHINE-001-testagent-2026-03-17` | Canonical discriminator |
| `session_name` | `Test Session - validation suite` | From input |
| `agent_name` | `TestAgent` | From input |
| `agent_slug` | `testagent` | From input |
| `agent` | `TestAgent (testagent)` | Combined label |
| `llm_model` | `claude-opus-4-6` | From input |
| `timezone` | `America/Sao_Paulo` | From input |
| `opened_at_local` | `2026-03-17 14:30` | From timestamp_local |
| `last_updated_at_local` | `2026-03-17 14:30` | Same as opened_at_local on creation |
| `closed_at_local` | `pending` | Not yet closed |
| `machine` | `TEST-MACHINE-001` | From machine_id |
| `context_type` | `Project` | From input |
| `project` | `test-project` | From input |
| `status` | `in_progress` | Initial status |

---

## Required Body Content

### Header block
- `**Data:**` = `2026-03-17`
- `**Maquina:**` = `TEST-MACHINE-001`
- `**Session ID:**` = `` `a1b2c3d4-e5f6-7890-abcd-ef1234567890` ``
- `**Session ID curto (filename):**` = `` `a1b2c3d4` ``
- `**Discriminador canonico operacional:**` = `` `a1b2c3d4-TEST-MACHINE-001-testagent-2026-03-17` ``
- `**Ultima atualizacao local:**` = `2026-03-17 14:30` (must match frontmatter — DH-02)
- `**Fechamento local real:**` = `pending`

### Discriminator coherence (DH-04)
- `session_key` in frontmatter MUST equal `Discriminador canonico operacional` in body
- Both must be: `a1b2c3d4-TEST-MACHINE-001-testagent-2026-03-17`

### Snapshot Atual table
- `Status geral` = `in_progress`
- `Projeto principal` = `test-project`
- `Clean-state gate` = `pending`

### Historico de Modificacoes
- First (and only) row contains: `2026-03-17 | [period] | 14:30 | America/Sao_Paulo | TestAgent (testagent) | TEST-MACHINE-001 | Criacao do session doc.`

---

## What Must NOT Be Present

| Prohibited Element | Reason |
|---|---|
| `{{SESSION_ID}}` or any `{{...}}` | All placeholders must be replaced (DH-06, FM-10) |
| `TODO` | Prohibited (PB-04) |
| `TBD` | Prohibited (PB-04) |
| `FIXME` | Prohibited (PB-04) |
| Hardcoded `C:\ai\` or `C:\Users\` in body | Cross-machine violation (T-XM-01) |
| Any path without `skills/` where required | Stale path (DH-05, FM-11) |

---

## Required Evidence Block

The agent must produce an evidence block in its response (not inside the file):

```
=== EVIDENCE: create-session ===
Operation: create-session
...
Checks:
  - Canonical discriminator present in frontmatter: YES
  - Canonical discriminator present in body: YES
  - All frontmatter fields non-empty: YES
  - Output path inside ai-sessions/YYYY-MM/: YES
  - Filename matches pattern: YES
  - No residual placeholders: YES
Result: PASS
=== END EVIDENCE ===
```

---

## Hygiene Checks (DH-01..DH-06)

- [ ] DH-01: Evidence block produced
- [ ] DH-02: `last_updated_at_local` frontmatter = `Ultima atualizacao local` body = `2026-03-17 14:30`
- [ ] DH-03: N/A for create-session (single initial history row)
- [ ] DH-04: Canonical discriminator in both frontmatter (session_key) and body
- [ ] DH-05: No stale paths in document
- [ ] DH-06: No `{{...}}`, TODO, TBD, FIXME in document
