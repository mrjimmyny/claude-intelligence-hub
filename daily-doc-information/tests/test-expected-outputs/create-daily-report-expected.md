# Expected Output: create-daily-report (T-DR-01)

**Test:** T-DR-01
**Operation:** create-daily-report
**Input fixture:** `test-fixtures/valid-create-daily-report-input.md`

---

## Output File

**Path:** `{BASE}/obsidian/CIH/projects/skills/test-project/daily-reports/daily-report-executive-2026-03-17-v1.md`

**Filename pattern check:** `daily-report-executive-[YYYY-MM-DD]-v1.md`
- date = `2026-03-17` ✓
- suffix = `-v1` ✓
- Output is inside `daily-reports/` ✓

---

## Required Frontmatter Fields

| Field | Required Value | Notes |
|---|---|---|
| `agents` | `[TestAgent]` | From source session docs |
| `sessions_covered` | `[a1b2c3d4-e5f6-7890-abcd-ef1234567890]` | From source session |
| `total_sessions` | `1` | One source doc |
| `report_date` | `2026-03-17` | From input |
| `author` | `testagent` | Agent that created the report |

---

## Required Body Content

### Sessoes Oficiais Vinculadas Table

Must have exactly one row (one source session doc):

| Session ID | Agent | Project | Status |
|---|---|---|---|
| `a1b2c3d4` (short) or full UUID | TestAgent | test-project | (status from source doc) |

### Snapshot Atual
- Must summarize work done in test-project on 2026-03-17

### Project Work Section
- Must have a section for `test-project`
- Key Actions: derived from source session's Historico de Modificacoes
- Major Decisions: derived from source session's Decisoes tables
- Blockers: derived from source session's Snapshot Atual

---

## What Must NOT Be Present

| Prohibited Element | Reason |
|---|---|
| `{{...}}` markers | DH-06, FM-10 |
| `TODO`, `TBD` | PB-04 |
| Empty sessions table | Every source doc must produce a row |
| Session docs from before 2026-03-13 | SC-08 guard |
| Content from other projects not in source_session_docs | PB-10 (NO_CROSS_SESSION_MERGE) |

---

## Source Doc Validation

Before creating the report, agent must verify:
1. All source docs exist and are readable
2. All source docs are dated 2026-03-13 or later (active range)
3. Output path is inside `daily-reports/` (SC-09 check)
4. Output path does NOT already exist (SC-07 check)

---

## Required Evidence Block

```
=== EVIDENCE: create-daily-report ===
Operation: create-daily-report
Timestamp: 2026-03-17 22:00
Agent: TestAgent (testagent)
Machine: TEST-MACHINE-001
Report Date: 2026-03-17
Source Docs: 1 documents
Output Path: {BASE}/obsidian/CIH/projects/skills/test-project/daily-reports/daily-report-executive-2026-03-17-v1.md
Checks:
  - All source docs in active range: YES
  - All source docs readable: YES
  - Output path inside daily-reports/: YES
  - Filename matches pattern: YES
  - No residual placeholders: YES
  - Sessions table complete: YES
Result: PASS
=== END EVIDENCE ===
```

---

## Hygiene Checks

- [ ] DH-01: Evidence block produced
- [ ] DH-06: No `{{...}}`, TODO, TBD in delivered document
- [ ] DH-05: No stale paths in document (all project paths include `skills/` where applicable)
- [ ] Output path is in `daily-reports/` directory (SC-09 guard)
- [ ] Filename matches `daily-report-executive-2026-03-17-v1.md`
