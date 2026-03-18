# Test Plan — daily-doc-information v0.3.0-prototype

**Version:** v1.0
**Date:** 2026-03-17
**Author:** Claude Sonnet 4.6 (headless AOP — task ddi-email-pt-r3-test-suite)
**Skill version under test:** 0.3.0-prototype
**Test type:** Specification-based (validates SKILL.md contract, not runtime execution)

---

## Methodology

These tests verify that:
1. The SKILL.md contract is implementable and complete
2. All 8 operations have unambiguous input/output specifications
3. All guardrails (SC, FM, PB, DH) are correctly defined and non-contradictory
4. Any LLM agent following SKILL.md would produce the expected behavior

**Status values:** `pending` | `pass` | `fail` | `blocked`

---

## Summary

| Category | Count | Coverage |
|---|---|---|
| Happy path | 8 | All 8 operations |
| Skip conditions | 9 | SC-01, SC-02, SC-03, SC-04, SC-05, SC-06, SC-07, SC-10, SC-11 |
| Failure modes | 6 | FM-01, FM-06, FM-08, FM-09, FM-10, FM-11 |
| Prohibited behaviors | 5 | PB-01, PB-02, PB-03, PB-04, PB-08 |
| Hygiene rules | 5 | DH-02, DH-03, DH-04, DH-05, DH-06 |
| Cross-compatibility | 2 | Cross-agent, cross-machine |
| **TOTAL** | **35** | |

---

## 1. Happy Path Tests

### T-CS-01 — create-session (happy path)

| Field | Value |
|---|---|
| **Test ID** | T-CS-01 |
| **Operation** | `create-session` |
| **Category** | Happy path |
| **Description** | Valid inputs produce a correctly populated session document at the specified output path |
| **Fixture** | `test-fixtures/valid-create-session-input.md` |
| **Expected output** | `test-expected-outputs/create-session-expected.md` |
| **What it validates** | All placeholders replaced, canonical discriminator in frontmatter and body, status=in_progress, filename matches pattern, evidence block produced |
| **Expected result** | PASS — new session doc created, evidence block shows all checks YES |
| **Status** | pending |

**Preconditions:**
- Output path does not exist
- All 6 universal inputs present
- session_id is a valid UUID (not fabricated by agent)

**Pass criteria:**
1. File created at `output_path`
2. `status: in_progress` in frontmatter
3. `session_key` = `a1b2c3d4-TEST-MACHINE-001-testagent-2026-03-17` in frontmatter
4. `Discriminador canonico operacional` matches session_key in body
5. No `{{...}}` markers remain
6. `opened_at_local` = `2026-03-17 14:30`
7. `closed_at_local` = `pending`
8. Evidence block Result = PASS

---

### T-US-01 — update-session (happy path)

| Field | Value |
|---|---|
| **Test ID** | T-US-01 |
| **Operation** | `update-session` |
| **Category** | Happy path |
| **Description** | Valid update-type=history adds new row at TOP of Historico de Modificacoes table |
| **Fixture** | `test-fixtures/valid-update-session-input.md` |
| **Expected output** | `test-expected-outputs/update-session-expected.md` |
| **What it validates** | DH-03 (prepend), DH-02 (timestamp coherence), evidence block |
| **Expected result** | PASS — history row added at top, last_updated_at_local updated in both locations |
| **Status** | pending |

**Preconditions:**
- Target file exists and has `status: in_progress`
- Target is not a legacy doc (not dated 2026-03-12 or earlier)

**Pass criteria:**
1. New history row appears ABOVE all previous rows in table
2. `last_updated_at_local` in frontmatter = `2026-03-17 15:00`
3. `Ultima atualizacao local` in body = `2026-03-17 15:00` (must match frontmatter — DH-02)
4. Content added is "Test validation run completed. All checks passed."
5. No stale paths or placeholders introduced
6. Evidence block Result = PASS

---

### T-CL-01 — close-session (happy path)

| Field | Value |
|---|---|
| **Test ID** | T-CL-01 |
| **Operation** | `close-session` |
| **Category** | Happy path |
| **Description** | All 6 clean-state criteria pass, session closed with status=complete |
| **Fixture** | `test-fixtures/valid-close-session-input.md` |
| **Expected output** | `test-expected-outputs/close-session-expected.md` |
| **What it validates** | CS-01..CS-06 evaluation, status set to complete, closed_at_local set, final history row added |
| **Expected result** | PASS — session doc marked complete, evidence block shows gate result PASS |
| **Status** | pending |

**Preconditions:**
- Target file exists and has `status: in_progress`
- clean_state_evidence covers all 6 criteria

**Pass criteria:**
1. `status: complete` in frontmatter
2. `closed_at_local` = `2026-03-17 16:00`
3. Final history row contains "Fechamento da sessao. Clean-state gate: PASS."
4. Snapshot Atual shows `Status geral: complete` and `Clean-state gate: PASS`
5. All 6 CS criteria reported as PASS in evidence
6. Evidence block Result = PASS

---

### T-DR-01 — create-daily-report (happy path)

| Field | Value |
|---|---|
| **Test ID** | T-DR-01 |
| **Operation** | `create-daily-report` |
| **Category** | Happy path |
| **Description** | One valid source session doc produces a consolidated daily report |
| **Fixture** | `test-fixtures/valid-create-daily-report-input.md` |
| **Expected output** | `test-expected-outputs/create-daily-report-expected.md` |
| **What it validates** | Template population, sessions table, output path in daily-reports/, no placeholders |
| **Expected result** | PASS — report created, Sessoes Oficiais table has one row |
| **Status** | pending |

**Preconditions:**
- Source session doc exists and is dated 2026-03-13 or later
- Output path does not exist
- output_path is inside `daily-reports/`

**Pass criteria:**
1. File created at `output_path`
2. Filename matches `daily-report-executive-2026-03-17-v1.md`
3. Sessions table has one row for session `a1b2c3d4`
4. No `{{...}}` markers remain
5. Evidence block shows all checks YES
6. Evidence block Result = PASS

---

### T-CP-01 — create-project (happy path)

| Field | Value |
|---|---|
| **Test ID** | T-CP-01 |
| **Operation** | `create-project` |
| **Category** | Happy path |
| **Description** | Valid skill project creation produces correct folder structure and 5 operational docs |
| **Fixture** | `test-fixtures/valid-create-project-input.md` |
| **Expected output** | `test-expected-outputs/create-project-expected.md` |
| **What it validates** | Folder structure for skill type, 5 docs created, project notes file, no placeholders, wikilinks |
| **Expected result** | PASS — folder and all docs created, evidence block shows all checks YES |
| **Status** | pending |

**Preconditions:**
- `projects/skills/test-new-project/` does not exist
- project_type = `skill`

**Pass criteria:**
1. Folder `projects/skills/test-new-project/` created
2. Subfolders created: `00_prompts_agents/`, `01-manifesto-contract/`, `02-planning/`, `03-spec/`, `04-tests/`, `05-audits/`, `06-operationalization/`, `07-templates/`, `ai-sessions/2026-03/`, `daily-reports/`
3. 5 operational docs exist: `PROJECT_CONTEXT.md`, `status-atual.md`, `next-step.md`, `decisoes.md`, `README.md`
4. Project notes file exists at `00_prompts_agents/ddi-pjt-gi-notes-ans-jimmy-orquestrator.md`
5. No `{{...}}` markers in any doc
6. All 5 docs have wikilinks (DH-13)
7. Evidence block Result = PASS

---

### T-PS-01 — update-project-status (happy path)

| Field | Value |
|---|---|
| **Test ID** | T-PS-01 |
| **Operation** | `update-project-status` |
| **Category** | Happy path |
| **Description** | Valid item added to `completed` section and Last Update refreshed |
| **Fixture** | `test-fixtures/valid-update-project-status-input.md` |
| **Expected output** | `test-expected-outputs/update-project-status-expected.md` |
| **What it validates** | Item in correct section, Last Update = current date, overall_progress updated, no placeholders |
| **Expected result** | PASS — status-atual.md updated |
| **Status** | pending |

**Preconditions:**
- `projects/skills/test-new-project/PROJECT_CONTEXT.md` exists (valid project path)
- `projects/skills/test-new-project/status-atual.md` exists
- section = `completed` (valid value)

**Pass criteria:**
1. New bullet under `Completed` section: "Initial project setup completed with all operational docs"
2. `Last Update` = `2026-03-17`
3. `Overall Progress` = "10% — structure created, implementation pending"
4. No placeholders introduced
5. Evidence block Result = PASS

---

### T-RD-01 — register-decision (happy path)

| Field | Value |
|---|---|
| **Test ID** | T-RD-01 |
| **Operation** | `register-decision` |
| **Category** | Happy path |
| **Description** | Valid decision added at TOP of decisoes.md with mandatory format |
| **Fixture** | `test-fixtures/valid-register-decision-input.md` |
| **Expected output** | `test-expected-outputs/register-decision-expected.md` |
| **What it validates** | Entry at top, mandatory Decision/Reason/Impact format (DH-11), wikilinks preserved |
| **Expected result** | PASS — decisoes.md updated with new entry at top |
| **Status** | pending |

**Preconditions:**
- `projects/skills/test-new-project/PROJECT_CONTEXT.md` exists
- `projects/skills/test-new-project/decisoes.md` exists
- All three fields (decision, reason, impact) non-empty

**Pass criteria:**
1. New entry appears ABOVE all previous entries (after `# Decision Log` header)
2. Entry has `## 2026-03-17` heading
3. `Decision:` field present with correct text
4. `Reason:` field present with correct text
5. `Impact:` field present with correct text
6. Wikilinks section preserved at bottom (DH-13)
7. Evidence block Result = PASS

---

### T-NS-01 — update-next-step (happy path)

| Field | Value |
|---|---|
| **Test ID** | T-NS-01 |
| **Operation** | `update-next-step` |
| **Category** | Happy path |
| **Description** | Immediate action replaced, required_reading and completion_criteria updated |
| **Fixture** | `test-fixtures/valid-update-next-step-input.md` |
| **Expected output** | `test-expected-outputs/update-next-step-expected.md` |
| **What it validates** | Immediate Action replaced, lists updated, wikilinks preserved, no placeholders |
| **Expected result** | PASS — next-step.md updated |
| **Status** | pending |

**Preconditions:**
- `projects/skills/test-new-project/PROJECT_CONTEXT.md` exists
- `projects/skills/test-new-project/next-step.md` exists
- immediate_action non-empty

**Pass criteria:**
1. `Immediate Action` = "Execute integration tests with real session docs"
2. `Required Reading` list = `[PROJECT_CONTEXT.md, status-atual.md, SKILL.md]`
3. `Completion Criteria` list updated with all 3 items
4. No placeholders introduced
5. Wikilinks preserved (DH-13)
6. Evidence block Result = PASS

---

## 2. Skip Condition Tests

### T-SC-01 — Invalid operation triggers SC-01

| Field | Value |
|---|---|
| **Test ID** | T-SC-01 |
| **Operation** | N/A (`delete-session` — invalid) |
| **Category** | Skip condition |
| **Skip condition** | SC-01 (INVALID_OPERATION) |
| **Description** | An unrecognized operation value fires SC-01 and aborts before any work |
| **Fixture** | `test-fixtures/negative-invalid-operation.md` |
| **Expected result** | ABORT with SC-01 — "INVALID_OPERATION: 'delete-session' is not one of the 8 valid operations" |
| **Status** | pending |

**Pass criteria:**
1. No files created or modified
2. Error message includes "SC-01" ID explicitly
3. Error message includes the invalid operation value received
4. Error message lists valid operations (per PB-06: no silent abort)

---

### T-SC-02 — Missing universal input triggers SC-02

| Field | Value |
|---|---|
| **Test ID** | T-SC-02 |
| **Operation** | `create-session` (missing agent_name, machine_id) |
| **Category** | Skip condition |
| **Skip condition** | SC-02 (MISSING_UNIVERSAL_INPUT) |
| **Description** | Absent required universal inputs fire SC-02 before any work begins |
| **Fixture** | `test-fixtures/negative-missing-inputs.md` |
| **Expected result** | ABORT with SC-02 — lists which inputs are missing |
| **Status** | pending |

**Pass criteria:**
1. No files created or modified
2. Error message includes "SC-02" ID explicitly
3. Error message names the specific missing fields (`agent_name`, `machine_id`)

---

### T-SC-03 — Missing session_id triggers SC-03

| Field | Value |
|---|---|
| **Test ID** | T-SC-03 |
| **Operation** | `create-session` (no session_id) |
| **Category** | Skip condition |
| **Skip condition** | SC-03 (SESSION_ID_ABSENT) |
| **Description** | create-session without session_id fires SC-03 and aborts — ID must come from outside |
| **Fixture** | `test-fixtures/negative-missing-session-id.md` |
| **Expected result** | ABORT with SC-03 — "SESSION_ID_ABSENT: session_id must be provided externally" |
| **Status** | pending |

**Pass criteria:**
1. No files created
2. Error includes "SC-03" explicitly
3. Error does NOT offer to generate a UUID (that would violate PB-01)

---

### T-SC-04 — Non-existent target triggers SC-04

| Field | Value |
|---|---|
| **Test ID** | T-SC-04 |
| **Operation** | `update-session` (target_path does not exist) |
| **Category** | Skip condition |
| **Skip condition** | SC-04 (TARGET_NOT_FOUND) |
| **Description** | update-session on a non-existent file fires SC-04 |
| **Fixture** | `test-fixtures/negative-missing-inputs.md` (with non-existent target_path) |
| **Expected result** | ABORT with SC-04 — includes the path that was not found |
| **Status** | pending |

**Pass criteria:**
1. No files modified
2. Error includes "SC-04" explicitly
3. Error includes the target_path that was checked

---

### T-SC-05 — Closed target triggers SC-05

| Field | Value |
|---|---|
| **Test ID** | T-SC-05 |
| **Operation** | `update-session` (target has status: complete) |
| **Category** | Skip condition |
| **Skip condition** | SC-05 (TARGET_ALREADY_CLOSED) |
| **Description** | Attempting to update a session doc with status=complete fires SC-05 |
| **Fixture** | `test-fixtures/negative-closed-target.md` |
| **Expected result** | ABORT with SC-05 — "TARGET_ALREADY_CLOSED: document status is 'complete'" |
| **Status** | pending |

**Pass criteria:**
1. No files modified
2. Error includes "SC-05" explicitly
3. Error confirms the doc is complete and cannot be updated

---

### T-SC-06 — Legacy target triggers SC-06

| Field | Value |
|---|---|
| **Test ID** | T-SC-06 |
| **Operation** | `update-session` (target dated 2026-03-10) |
| **Category** | Skip condition |
| **Skip condition** | SC-06 (TARGET_IS_LEGACY) |
| **Description** | Attempting to modify a doc dated 2026-03-12 or earlier fires SC-06 |
| **Fixture** | `test-fixtures/negative-legacy-target.md` |
| **Expected result** | ABORT with SC-06 — "TARGET_IS_LEGACY: document is frozen (dated 2026-03-10)" |
| **Status** | pending |

**Pass criteria:**
1. No files modified
2. Error includes "SC-06" explicitly
3. Error includes the document date
4. Error states the doc is frozen / legacy

---

### T-SC-07 — Existing output triggers SC-07

| Field | Value |
|---|---|
| **Test ID** | T-SC-07 |
| **Operation** | `create-session` (output_path already exists) |
| **Category** | Skip condition |
| **Skip condition** | SC-07 (OUTPUT_ALREADY_EXISTS) |
| **Description** | create-session fires SC-07 instead of overwriting existing file |
| **Fixture** | `test-fixtures/negative-output-exists.md` |
| **Expected result** | ABORT with SC-07 — "OUTPUT_ALREADY_EXISTS: will not overwrite existing file" |
| **Status** | pending |

**Pass criteria:**
1. Existing file NOT overwritten
2. Error includes "SC-07" explicitly
3. Error includes the path that already exists

---

### T-SC-10 — Invalid project path triggers SC-10

| Field | Value |
|---|---|
| **Test ID** | T-SC-10 |
| **Operation** | `update-project-status` (project_path has no PROJECT_CONTEXT.md) |
| **Category** | Skip condition |
| **Skip condition** | SC-10 (PROJECT_PATH_INVALID) |
| **Description** | project_path without PROJECT_CONTEXT.md fires SC-10 before any modification |
| **Fixture** | `test-fixtures/negative-invalid-project-path.md` |
| **Expected result** | ABORT with SC-10 — "PROJECT_PATH_INVALID: PROJECT_CONTEXT.md not found at path" |
| **Status** | pending |

**Pass criteria:**
1. No files modified
2. Error includes "SC-10" explicitly
3. Error names the specific path that was checked

---

### T-SC-11 — Existing project triggers SC-11

| Field | Value |
|---|---|
| **Test ID** | T-SC-11 |
| **Operation** | `create-project` (target folder already exists) |
| **Category** | Skip condition |
| **Skip condition** | SC-11 (PROJECT_ALREADY_EXISTS) |
| **Description** | create-project fires SC-11 if destination folder already exists |
| **Fixture** | `test-fixtures/negative-project-exists.md` |
| **Expected result** | ABORT with SC-11 — "PROJECT_ALREADY_EXISTS: will not overwrite existing project" |
| **Status** | pending |

**Pass criteria:**
1. No files created or overwritten
2. Error includes "SC-11" explicitly
3. Error includes the existing folder path

---

## 3. Failure Mode Tests

### T-FM-01 — SESSION_ID_ABSENT escalates

| Field | Value |
|---|---|
| **Test ID** | T-FM-01 |
| **Operation** | `create-session` |
| **Category** | Failure mode |
| **Failure mode** | FM-01 (SESSION_ID_ABSENT) |
| **Description** | If agent attempts to fabricate a UUID, FM-01 fires and execution stops immediately with escalation |
| **What it validates** | PB-01 is enforceable: agent must NOT generate IDs even if tempted |
| **Expected result** | STOP + ESCALATE — "FM-01: SESSION_ID_ABSENT — escalating to Jimmy" |
| **Status** | pending |

**Pass criteria:**
1. No document created
2. Response includes "FM-01" explicitly
3. Response includes "escalating" or equivalent escalation signal
4. Agent does NOT offer an alternative UUID it generated

**Spec completeness check:**
- FM-01 trigger is clearly defined: "Agent attempts to fabricate a session ID"
- Fallback action is clear: "Stop immediately. Escalate to Jimmy. Do not proceed."
- SC-03 and FM-01 together form a two-layer defense for this critical guardrail

---

### T-FM-06 — Legacy doc modification stops immediately

| Field | Value |
|---|---|
| **Test ID** | T-FM-06 |
| **Operation** | `update-session` (doc dated 2026-03-10 passed SC-06 check and reached execution) |
| **Category** | Failure mode |
| **Failure mode** | FM-06 (TARGET_IS_LEGACY) |
| **Description** | If a legacy doc somehow passes SC-06 and execution begins, FM-06 fires during execution |
| **What it validates** | PB-07 double-guard: both SC-06 (pre-flight) and FM-06 (runtime) protect legacy docs |
| **Expected result** | STOP + ESCALATE — "FM-06: TARGET_IS_LEGACY — escalating to Jimmy. Legacy docs are frozen." |
| **Status** | pending |

**Pass criteria:**
1. Document not modified
2. Response includes "FM-06" explicitly
3. Response includes escalation signal
4. Response states document is frozen/legacy

---

### T-FM-08 — Write surface violation stops immediately

| Field | Value |
|---|---|
| **Test ID** | T-FM-08 |
| **Operation** | `create-session` attempting to write to NW surface |
| **Category** | Failure mode |
| **Failure mode** | FM-08 (WRITE_SURFACE_VIOLATION) |
| **Description** | Attempting to write outside allowed write surfaces fires FM-08 immediately |
| **What it validates** | Section 14 write surfaces are enforceable; PB-03 (NO_NW_WRITE) is respected |
| **Expected result** | STOP + ESCALATE — "FM-08: WRITE_SURFACE_VIOLATION — escalating to Jimmy and audit lead" |
| **Status** | pending |

**Test scenario:** create-session with output_path pointing to `02-planning/` (NW-05)

**Pass criteria:**
1. No write attempted
2. Response includes "FM-08" explicitly
3. Response includes escalation to both "Jimmy" and "audit lead"
4. Response identifies the disallowed path

**Spec completeness check:**
- FM-08 severity = Critical
- Both "Jimmy" and "audit lead" must be notified per spec
- NW-05 (`02-planning/`) is in non-writable surfaces list

---

### T-FM-09 — Clean-state blocked returns failing criteria

| Field | Value |
|---|---|
| **Test ID** | T-FM-09 |
| **Operation** | `close-session` (CS-03 fails — no decisions recorded) |
| **Category** | Failure mode |
| **Failure mode** | FM-09 (CLEAN_STATE_BLOCKED) |
| **Description** | One failing clean-state criterion blocks close. Gate result returned. Document NOT modified. |
| **What it validates** | PB-02 (NO_PARTIAL_CLOSE): all 6 criteria must pass before any modification |
| **Expected result** | BLOCKED gate result — itemized criteria, CS-03 shown as BLOCKED, document unchanged |
| **Status** | pending |

**Pass criteria:**
1. Document status NOT changed to `complete`
2. Gate result shows all 6 criteria individually (DH-10)
3. CS-03 shows BLOCKED with explanation
4. Passing criteria shown as PASS
5. Response includes "FM-09" explicitly
6. "STOP. Do NOT modify the document." behavior observed

---

### T-FM-10 — Placeholder detected rejects artifact

| Field | Value |
|---|---|
| **Test ID** | T-FM-10 |
| **Operation** | `create-session` (would produce output with unresolved `{{BLOCK_TITLE}}`) |
| **Category** | Failure mode |
| **Failure mode** | FM-10 (PLACEHOLDER_DETECTED) |
| **Description** | If output contains any `{{...}}` marker, FM-10 fires and document is not delivered |
| **What it validates** | PB-04 (NO_DIRTY_ARTIFACT): clean outputs only |
| **Expected result** | FAIL — document not written; "FM-10: PLACEHOLDER_DETECTED — fix before writing" |
| **Status** | pending |

**Pass criteria:**
1. File NOT written to disk if it would contain `{{...}}`
2. Response includes "FM-10" explicitly
3. Response identifies which placeholder(s) remain
4. Agent does not deliver partial artifact

---

### T-FM-11 — Stale path detected rejects artifact

| Field | Value |
|---|---|
| **Test ID** | T-FM-11 |
| **Operation** | `create-session` or `update-session` introducing a path without `skills/` segment |
| **Category** | Failure mode |
| **Failure mode** | FM-11 (STALE_PATH_DETECTED) |
| **Description** | If output contains old-format paths missing the `skills/` segment, FM-11 fires |
| **What it validates** | DH-05 (NO_STALE_PATHS) is enforced as a failure mode |
| **Expected result** | FAIL — document not delivered; "FM-11: STALE_PATH_DETECTED — fix before writing" |
| **Status** | pending |

**Pass criteria:**
1. Document not delivered if it contains stale paths
2. Response includes "FM-11" explicitly
3. Response identifies the stale path(s)
4. Difference between valid path (`projects/skills/foo`) and stale path (`projects/foo`) is stated

---

## 4. Prohibited Behavior Tests

### T-PB-01 — No ID fabrication

| Field | Value |
|---|---|
| **Test ID** | T-PB-01 |
| **Operation** | `create-session` |
| **Category** | Prohibited behavior |
| **Rule** | PB-01 (NO_ID_FABRICATION) |
| **Description** | Skill spec must be unambiguous: agent NEVER generates session IDs |
| **What it validates** | SKILL.md clearly states IDs must come externally; no ambiguous language allows agent to self-generate |
| **Expected result** | SKILL.md text: SC-03 fires if absent, FM-01 fires if agent attempts fabrication |
| **Status** | pending |

**Spec audit checklist:**
- [ ] SC-03 description says "session_id not provided for create-session"
- [ ] FM-01 trigger says "Agent attempts to fabricate a session ID"
- [ ] PB-01 rule says "Never generate, invent, or guess session IDs"
- [ ] No section in SKILL.md says "if session_id not provided, generate one"
- [ ] create-session inputs table explicitly states "MUST be provided externally, NEVER fabricated by agent"

---

### T-PB-02 — No partial close

| Field | Value |
|---|---|
| **Test ID** | T-PB-02 |
| **Operation** | `close-session` |
| **Category** | Prohibited behavior |
| **Rule** | PB-02 (NO_PARTIAL_CLOSE) |
| **Description** | Skill spec must be unambiguous: status=complete only set after all 6 CS criteria pass |
| **What it validates** | Execution steps 5 and 6 are mutually exclusive (BLOCKED → do not modify; ALL PASS → close) |
| **Expected result** | No code path in SKILL.md allows partial closure |
| **Status** | pending |

**Spec audit checklist:**
- [ ] close-session step 5: "If ANY criterion is BLOCKED → STOP. Do NOT modify the document."
- [ ] close-session step 6: "If ALL criteria PASS → set status to complete"
- [ ] FM-09 fires when gate is BLOCKED (reinforcement)
- [ ] No step between 5 and 6 that could set status=complete with partial criteria

---

### T-PB-03 — No write to non-writable surfaces

| Field | Value |
|---|---|
| **Test ID** | T-PB-03 |
| **Operation** | All operations |
| **Category** | Prohibited behavior |
| **Rule** | PB-03 (NO_NW_WRITE) |
| **Description** | Section 14 NW surfaces are clearly defined and must be referenced in FM-08 |
| **What it validates** | NW-01..NW-10 surfaces are enumerated; FM-08 is the enforcement mechanism |
| **Expected result** | SKILL.md has complete NW surface list and FM-08 says "stop immediately" |
| **Status** | pending |

**Spec audit checklist:**
- [ ] NW-01 through NW-10 all defined in Section 14
- [ ] FM-08 severity = Critical
- [ ] FM-08 fallback = "Stop immediately. Escalate to Jimmy and audit lead. Do not write."
- [ ] At least one NW surface is `PROJECT_CONTEXT.md` (frozen after creation)
- [ ] Templates (NW-09, NW-10) are in NW list, enforced by PB-08

---

### T-PB-04 — No dirty artifact

| Field | Value |
|---|---|
| **Test ID** | T-PB-04 |
| **Operation** | All operations producing output |
| **Category** | Prohibited behavior |
| **Rule** | PB-04 (NO_DIRTY_ARTIFACT) |
| **Description** | SKILL.md explicitly prohibits delivering any document with TODO, TBD, FIXME, or {{...}} |
| **What it validates** | DH-06 and FM-10 together enforce artifact cleanliness |
| **Expected result** | DH-06 + FM-10 form a two-layer check preventing placeholder delivery |
| **Status** | pending |

**Spec audit checklist:**
- [ ] DH-06 rule: "No {{...}} template markers, TODO, TBD, or FIXME in delivered documents"
- [ ] FM-10 trigger: "Output document contains {{...}}, TODO, TBD, or pending as a value"
- [ ] PB-04 rule includes FIXME in addition to TODO/TBD
- [ ] Each operation's execution steps includes a "Verify no residual placeholders" step
- [ ] FM-10 says "Do not deliver artifact. Fix all placeholders before writing."

---

### T-PB-08 — No template modification

| Field | Value |
|---|---|
| **Test ID** | T-PB-08 |
| **Operation** | Any operation reading templates |
| **Category** | Prohibited behavior |
| **Rule** | PB-08 (NO_TEMPLATE_MODIFICATION) |
| **Description** | Template files must be in read-only (RS) surfaces and not in any write surface |
| **What it validates** | `ai-session-template.md` and `daily-report-template.md` are RS-only, in NW list |
| **Expected result** | Templates appear in RS-01/RS-03 (read) and NW-09/NW-10 (no-write) — not in any WS |
| **Status** | pending |

**Spec audit checklist:**
- [ ] `ai-sessions/ai-session-template.md` is RS-01 (read) and NW-09 (no-write)
- [ ] `daily-reports/daily-report-template.md` is RS-03 (read) and NW-10 (no-write)
- [ ] Neither template path appears in WS-01..WS-07 (write surfaces)
- [ ] PB-08 references both RS-01 and RS-03 by ID

---

## 5. Hygiene Rule Tests

### T-DH-02 — Timestamp coherence

| Field | Value |
|---|---|
| **Test ID** | T-DH-02 |
| **Operation** | `update-session`, `close-session` |
| **Category** | Hygiene rule |
| **Rule** | DH-02 (TIMESTAMP_COHERENCE) |
| **Description** | `last_updated_at_local` in frontmatter must equal `Ultima atualizacao local` in body |
| **What it validates** | Both locations update together; mismatch triggers FM-03 |
| **Expected result** | After any update, both timestamp values are identical |
| **Status** | pending |

**Spec audit checklist:**
- [ ] update-session step 5: "Update last_updated_at_local in BOTH frontmatter AND body"
- [ ] update-session evidence check: "last_updated_at_local frontmatter matches body: YES/NO"
- [ ] close-session step 6: "Update last_updated_at_local to timestamp_local in frontmatter AND body"
- [ ] FM-03 (TIMESTAMP_DRIFT) is the escalation path if mismatch detected

---

### T-DH-03 — History rows prepended at top

| Field | Value |
|---|---|
| **Test ID** | T-DH-03 |
| **Operation** | `update-session` (update_type=history), `close-session` |
| **Category** | Hygiene rule |
| **Rule** | DH-03 (HISTORY_PREPEND) |
| **Description** | New history rows appear at TOP of Historico de Modificacoes table (newest first) |
| **What it validates** | Placement rule "Prepend" in update-session section 4 |
| **Expected result** | After update, new row is the first data row in the table |
| **Status** | pending |

**Spec audit checklist:**
- [ ] update-session section 4, `history` row: "Prepend new row at TOP (newest first, per DH-03)"
- [ ] Template body has reminder: "Regra: novas linhas entram no topo da tabela."
- [ ] FM-04 (HISTORY_ORDER_VIOLATION) fires if row appended at bottom instead
- [ ] close-session step 6: "Prepend final history row"

---

### T-DH-04 — Canonical discriminator present

| Field | Value |
|---|---|
| **Test ID** | T-DH-04 |
| **Operation** | `create-session` |
| **Category** | Hygiene rule |
| **Rule** | DH-04 (CANONICAL_DISCRIMINATOR) |
| **Description** | Canonical discriminator must appear in BOTH frontmatter (session_key) AND body |
| **What it validates** | create-session step 3 computes and places discriminator in both locations |
| **Expected result** | `session_key` frontmatter value = `Discriminador canonico operacional` body value |
| **Status** | pending |

**Spec audit checklist:**
- [ ] create-session step 3: "Compute canonical discriminator: [session_id_short]-[machine_id]-[agent_slug]-[YYYY-MM-DD]"
- [ ] create-session step 4: session_key set to discriminator in frontmatter
- [ ] create-session evidence check: "Canonical discriminator present in frontmatter: YES/NO"
- [ ] create-session evidence check: "Canonical discriminator present in body: YES/NO"
- [ ] FM-02 (DISCRIMINATOR_MISMATCH) fires if they differ

---

### T-DH-05 — No stale paths

| Field | Value |
|---|---|
| **Test ID** | T-DH-05 |
| **Operation** | All operations producing output |
| **Category** | Hygiene rule |
| **Rule** | DH-05 (NO_STALE_PATHS) |
| **Description** | All paths in output docs must include `skills/` segment where applicable |
| **What it validates** | FM-11 enforces this at runtime; each operation checks for stale paths |
| **Expected result** | SKILL.md defines stale vs valid path format; FM-11 is the guard |
| **Status** | pending |

**Spec audit checklist:**
- [ ] DH-05 rule: "All paths in documents must include the skills/ segment where applicable"
- [ ] DH-05 specifies what "stale" means: "Old-format paths without skills/ are stale"
- [ ] FM-11 trigger: "Output document contains a path without the skills/ segment where required"
- [ ] update-session execution step includes "Verify no stale paths introduced (DH-05)"

---

### T-DH-06 — No placeholders in output

| Field | Value |
|---|---|
| **Test ID** | T-DH-06 |
| **Operation** | All operations producing output |
| **Category** | Hygiene rule |
| **Rule** | DH-06 (NO_PLACEHOLDERS) |
| **Description** | Delivered documents must have zero `{{...}}`, TODO, TBD, FIXME markers |
| **What it validates** | Each operation has explicit "Verify no residual placeholders" step; FM-10 guards delivery |
| **Expected result** | All 8 operations check for placeholders before writing |
| **Status** | pending |

**Spec audit checklist:**
- [ ] create-session step 7: "Verify no residual placeholders"
- [ ] update-session step 6: "Verify no stale paths or placeholders were introduced (DH-05, DH-06)"
- [ ] create-project step 7: "Verify no residual placeholders in any of the 5 docs"
- [ ] update-project-status step 8: "Verify no placeholders were introduced (DH-06)"
- [ ] register-decision step 7: "Verify no placeholders were introduced (DH-06)"
- [ ] update-next-step step 8: "Verify no placeholders were introduced (DH-06)"

---

## 6. Cross-Compatibility Tests

### T-XA-01 — No agent-specific tool references

| Field | Value |
|---|---|
| **Test ID** | T-XA-01 |
| **Operation** | All |
| **Category** | Cross-agent compatibility |
| **Description** | Operational instructions in SKILL.md must not reference agent-specific tools (Read, Write, Edit, etc.) |
| **What it validates** | Cross-Agent Compatibility section guarantee: any agent can follow the instructions |
| **Expected result** | Instructions use generic verbs ("read file X", "write file Y") not tool names |
| **Status** | pending |

**Spec audit checklist:**
- [ ] Cross-Agent Compatibility section exists in SKILL.md (confirmed present)
- [ ] Operational steps use "Read existing document", "Write the populated document" (generic)
- [ ] No step says "Use the Read tool" or "Use Write tool" or "use bash"
- [ ] Compatibility table lists Claude, Codex, Gemini as tested
- [ ] "Agent-specific adaptation" section explains that each agent uses its own tooling

---

### T-XM-01 — No hardcoded paths in outputs

| Field | Value |
|---|---|
| **Test ID** | T-XM-01 |
| **Operation** | All |
| **Category** | Cross-machine compatibility |
| **Description** | SKILL.md operational instructions must not contain hardcoded absolute paths |
| **What it validates** | Environment Configuration section: {BASE} is used, not C:\ai\ |
| **Expected result** | All operational instructions reference {BASE} or relative paths, not hardcoded user/machine paths |
| **Status** | pending |

**Spec audit checklist:**
- [ ] Environment Configuration section uses `{BASE}` not `C:\ai\` in operational rules
- [ ] "Configuration rules" #4 states: "User-specific paths (like C:\Users\{username}\) are NEVER part of the skill's path structure"
- [ ] All SC/FM/PB/DH rules reference path concepts abstractly, not with hardcoded roots
- [ ] Fixtures in this test suite use `{BASE}` (not hardcoded C:\ai\)
- [ ] Expected outputs in this test suite use `{BASE}` (not hardcoded C:\ai\)

---

## Appendix A: SC Coverage Matrix

| SC ID | Name | Applies To | Test |
|---|---|---|---|
| SC-01 | INVALID_OPERATION | all | T-SC-01 |
| SC-02 | MISSING_UNIVERSAL_INPUT | all | T-SC-02 |
| SC-03 | SESSION_ID_ABSENT | create-session | T-SC-03 |
| SC-04 | TARGET_NOT_FOUND | update-session, close-session | T-SC-04 |
| SC-05 | TARGET_ALREADY_CLOSED | update-session, close-session | T-SC-05 |
| SC-06 | TARGET_IS_LEGACY | all | T-SC-06 |
| SC-07 | OUTPUT_ALREADY_EXISTS | create-session, create-daily-report | T-SC-07 |
| SC-08 | SOURCE_RANGE_VIOLATION | create-daily-report | (covered by spec audit — T-XM-01) |
| SC-09 | OUTPUT_PATH_OUT_OF_BOUNDS | create-session, create-daily-report | (covered by spec audit — T-XA-01) |
| SC-10 | PROJECT_PATH_INVALID | update-project-status, register-decision, update-next-step | T-SC-10 |
| SC-11 | PROJECT_ALREADY_EXISTS | create-project | T-SC-11 |
| SC-12 | MISSING_PROJECT_INPUT | all project ops | (covered by T-SC-02 analog) |

## Appendix B: FM Coverage Matrix

| FM ID | Name | Severity | Test |
|---|---|---|---|
| FM-01 | SESSION_ID_ABSENT | Critical | T-FM-01 |
| FM-02 | DISCRIMINATOR_MISMATCH | High | T-DH-04 (spec audit) |
| FM-03 | TIMESTAMP_DRIFT | High | T-DH-02 (spec audit) |
| FM-04 | HISTORY_ORDER_VIOLATION | Medium | T-DH-03 (spec audit) |
| FM-05 | SECTION_MISMATCH | High | (implicit in T-US-01) |
| FM-06 | TARGET_IS_LEGACY | Critical | T-FM-06 |
| FM-07 | DUPLICATE_SESSION_DOC | High | T-SC-07 |
| FM-08 | WRITE_SURFACE_VIOLATION | Critical | T-FM-08 |
| FM-09 | CLEAN_STATE_BLOCKED | High | T-FM-09 |
| FM-10 | PLACEHOLDER_DETECTED | High | T-FM-10 |
| FM-11 | STALE_PATH_DETECTED | High | T-FM-11 |
| FM-12 | TEMPLATE_READ_FAILURE | High | (spec audit — T-PB-08) |
| FM-13 | SOURCE_DOC_UNREADABLE | Medium | (implicit in T-DR-01) |
| FM-14 | PROJECT_STRUCTURE_INCOMPLETE | High | (implicit in T-CP-01) |
| FM-15 | PROJECT_DOC_NOT_FOUND | High | (implicit in T-PS-01, T-RD-01, T-NS-01) |
| FM-16 | PROJECT_STATUS_SECTION_INVALID | High | (implicit in T-PS-01) |
