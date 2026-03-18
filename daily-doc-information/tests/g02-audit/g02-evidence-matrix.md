# G-02 Evidence Matrix

> Maps every spec requirement to its location in the SKILL.md v0.3.1-prototype.
> Date: 2026-03-18 | Auditor: Claude Opus 4.6 (headless AOP — audit role)

---

## Round 01 — Automation Boundary Contract

### In-Scope Capabilities

| Spec | Requirement | SKILL.md Location | Verified |
|---|---|---|---|
| R01 IS-01 | Session document creation | Section 2 (create-session) | PASS |
| R01 IS-02 | Session document update | Section 3 (update-session) | PASS |
| R01 IS-03 | Canonical discriminator enforcement | DH-04 (Section 13), create-session step 3 | PASS |
| R01 IS-04 | Mandatory-field validation | SC-02, SC-12 (Section 10), execution steps in all ops | PASS |
| R01 IS-05 | Clean-state gate check | Section 4 (close-session), CS-01..CS-06 | PASS |
| R01 IS-06 | Daily report creation | Section 5 (create-daily-report) | PASS |
| R01 IS-07 | Hygiene validation | DH-05, DH-06 (Section 13), verification steps in all ops | PASS |
| R01 IS-08 | Validation summary production | Evidence block templates in Sections 2-9 | PASS |

### Out-of-Scope Items

| Spec | Requirement | SKILL.md Location | Verified |
|---|---|---|---|
| R01 OS-01 | No implementation of other skills/code | Scope section (lines 21-25) | PASS |
| R01 OS-02 | No publishing to hub | Not in any operation definition | PASS |
| R01 OS-03 | No docs dated 2026-03-12 or earlier | SC-06 (Section 10), PB-07 (Section 12) | PASS |
| R01 OS-04 | No migration of existing data | Not in any operation definition | PASS |
| R01 OS-05 | No audit decisions | Not in any operation definition | PASS |
| R01 OS-06 | No project-level decisions | PB-11, PB-13 (Section 12) | PASS |
| R01 OS-07 | No git operations | PB-05 (Section 12) | PASS |
| R01 OS-08 | No speculative implementation | Scope section (lines 21-25) | PASS |
| R01 OS-09 | No multi-project normalization | PB-15 (Section 12) | PASS |

### Manual-by-Design Items

| Spec | Requirement | SKILL.md Location | Verified |
|---|---|---|---|
| R01 MBD-01 | Session ID from external source | PB-01, SC-03, FM-01 | PASS |
| R01 MBD-02 | Audit verdict by auditor | Not in skill scope (correct) | PASS |
| R01 MBD-03 | Round advancement by Jimmy+auditor | Not in skill scope (correct) | PASS |
| R01 MBD-04 | Commit/push requires human auth | PB-05 NO_VCS_OPERATION | PASS |
| R01 MBD-05 | Project-level scope decisions by Jimmy | PB-11 NO_SCOPE_CREEP | PASS |
| R01 MBD-06 | Clean-state closure confirmation | CS-01..06, DH-10 itemized evidence | PASS |
| R01 MBD-07 | Promotion/publication gate by Jimmy | Not in skill scope (correct) | PASS |

### "Must Never Do" Rules

| Spec | Rule | SKILL.md Location | Verified |
|---|---|---|---|
| R01 ND-1 | Generate/overwrite session IDs | PB-01 NO_ID_FABRICATION | PASS |
| R01 ND-2 | Mark complete without clean-state | PB-02 NO_PARTIAL_CLOSE | PASS |
| R01 ND-3 | Bypass audit gate between rounds | Scope section (not in skill's authority) | PASS |
| R01 ND-4 | Touch frozen legacy documents | PB-07 NO_LEGACY_MODIFICATION, SC-06 | PASS |
| R01 ND-5 | Open round before current audited | Scope section (not in skill's authority) | PASS |
| R01 ND-6 | Produce placeholder artifacts | PB-04 NO_DIRTY_ARTIFACT | PASS |
| R01 ND-7 | Speculate beyond scope | PB-11 NO_SCOPE_CREEP | PASS |
| R01 ND-8 | Write doc without discriminator | DH-04 CANONICAL_DISCRIMINATOR | PASS |

---

## Round 02 — I/O Contract

### Operations

| Spec | Requirement | SKILL.md Location | Verified |
|---|---|---|---|
| R02 OP-1 | create-session | Section 2 | PASS |
| R02 OP-2 | update-session | Section 3 | PASS |
| R02 OP-3 | close-session | Section 4 | PASS |
| R02 OP-4 | create-daily-report | Section 5 | PASS |

### Mandatory Inputs

| Spec | Input | SKILL.md Location | Verified |
|---|---|---|---|
| R02 I-01 | `operation` | Section 1, I-01 | PASS |
| R02 I-02 | `agent_name` | Section 1, I-02 | PASS |
| R02 I-03 | `agent_slug` | Section 1, I-03 | PASS |
| R02 I-04 | `machine_id` | Section 1, I-04 | PASS |
| R02 I-05 | `timestamp_local` | Section 1, I-05 | PASS |
| R02 I-06 | `timezone` | Section 1, I-06 | PASS |
| R02 I-10 | `session_id` | Section 2 Additional Inputs | PASS |
| R02 I-11 | `session_id_short` | Section 2 Additional Inputs | PASS |
| R02 I-12 | `project` | Section 2 Additional Inputs | PASS |
| R02 I-13 | `context_type` | Section 2 Additional Inputs | PASS |
| R02 I-14 | `session_name` | Section 2 Additional Inputs | PASS |
| R02 I-15 | `template_path` | Not explicit — embedded templates (Section 15) used instead | WARN (GA-01) |
| R02 I-16 | `output_path` | Section 2 Additional Inputs | PASS |
| R02 I-20 | `target_path` | Section 3 Additional Inputs | PASS |
| R02 I-21 | `update_type` | Section 3 Additional Inputs | PASS |
| R02 I-22 | `update_content` | Section 3 Additional Inputs | PASS |
| R02 I-30 | `target_path` | Section 4 Additional Inputs | PASS |
| R02 I-31 | `clean_state_evidence` | Section 4 Additional Inputs | PASS |
| R02 I-40 | `report_date` | Section 5 Additional Inputs | PASS |
| R02 I-41 | `source_session_docs` | Section 5 Additional Inputs | PASS |
| R02 I-42 | `template_path` | Not explicit — embedded templates (Section 15) used instead | WARN (GA-01) |
| R02 I-43 | `output_path` | Section 5 Additional Inputs | PASS |

### Mandatory Outputs

| Spec | Output | SKILL.md Location | Verified |
|---|---|---|---|
| R02 O-01 | New session document | Section 2 Outputs + step 7 | PASS |
| R02 O-02 | Validation summary (create-session) | Section 2 Evidence block | PASS |
| R02 O-10 | Updated session document | Section 3 Outputs + step 7 | PASS |
| R02 O-11 | Validation summary (update-session) | Section 3 Evidence block | PASS |
| R02 O-20 | Gate result (PASS/BLOCKED) | Section 4 Outputs + steps 5-6 | PASS |
| R02 O-21 | Closed session document | Section 4 step 6 | PASS |
| R02 O-22 | Closure evidence | Section 4 Evidence block | PASS |
| R02 O-30 | New daily report | Section 5 Outputs + step 8 | PASS |
| R02 O-31 | Validation summary (daily-report) | Section 5 Evidence block | PASS |

### Read Surfaces

| Spec | Surface | SKILL.md Location | Verified |
|---|---|---|---|
| R02 RS-01 | `ai-sessions/ai-session-template.md` | Section 14, RS-01 | PASS |
| R02 RS-02 | `ai-sessions/YYYY-MM/*.md` | Section 14, RS-02 | PASS |
| R02 RS-03 | `daily-reports/daily-report-template.md` | Section 14, RS-03 | PASS |
| R02 RS-04 | `daily-reports/*.md` | Section 14, RS-04 | PASS |
| R02 RS-05 | `PROJECT_CONTEXT.md` | Section 14, RS-05 | PASS |

### Write Surfaces

| Spec | Surface | SKILL.md Location | Verified |
|---|---|---|---|
| R02 WS-01 | `ai-sessions/YYYY-MM/<new-session>.md` | Section 14, WS-01 | PASS |
| R02 WS-02 | `ai-sessions/YYYY-MM/<existing-session>.md` | Section 14, WS-02 | PASS |
| R02 WS-03 | `daily-reports/<new-report>.md` | Section 14, WS-03 | PASS |

### Non-Writable Surfaces

| Spec | Surface | SKILL.md Location | Verified |
|---|---|---|---|
| R02 NW-01 | Session docs ≤2026-03-12 | SC-06 TARGET_IS_LEGACY, PB-07 NO_LEGACY_MODIFICATION | PASS (via SC/PB, not NW table) |
| R02 NW-02 | Daily reports ≤2026-03-12 | SC-06 TARGET_IS_LEGACY, PB-07 NO_LEGACY_MODIFICATION | PASS (via SC/PB, not NW table) |
| R02 NW-03 | `PROJECT_CONTEXT.md` | Section 14, NW-01 | PASS |
| R02 NW-04 | `status-atual.md` | Section 14, NW-02 (with project ops exemption) | PASS |
| R02 NW-05 | `next-step.md` | Section 14, NW-03 (with project ops exemption) | PASS |
| R02 NW-06 | `decisoes.md` | Section 14, NW-04 (with project ops exemption) | PASS |
| R02 NW-07 | `03-spec/`, `04-tests/`, etc. | Section 14, NW-05..NW-08 | PASS |
| R02 NW-08 | Any path outside session/report dirs | FM-08 WRITE_SURFACE_VIOLATION, WS boundaries | PASS (via FM/WS, not NW table) |
| R02 NW-09 | `ai-sessions/ai-session-template.md` | Section 14, NW-09 | PASS |
| R02 NW-10 | `daily-reports/daily-report-template.md` | Section 14, NW-10 | PASS |

### Clean-State Gate

| Spec | Criterion | SKILL.md Location | Verified |
|---|---|---|---|
| R02 CS-01 | `next_action` single and explicit | Section 4 CS-01 | PASS |
| R02 CS-02 | `blockers` declared | Section 4 CS-02 | PASS |
| R02 CS-03 | At least one decision recorded | Section 4 CS-03 | PASS |
| R02 CS-04 | At least one validation recorded | Section 4 CS-04 | PASS |
| R02 CS-05 | Temporary artifacts accounted for | Section 4 CS-05 | PASS |
| R02 CS-06 | Commit/push justification stated | Section 4 CS-06 | PASS |

---

## Round 03 — Guardrails and Failure Modes

### Skip Conditions

| Spec | Condition | SKILL.md Location | Verified |
|---|---|---|---|
| R03 SC-01 | INVALID_OPERATION | Section 10, SC-01 (extended to 8 valid values) | PASS |
| R03 SC-02 | MISSING_UNIVERSAL_INPUT | Section 10, SC-02 | PASS |
| R03 SC-03 | SESSION_ID_ABSENT | Section 10, SC-03 | PASS |
| R03 SC-04 | TARGET_NOT_FOUND | Section 10, SC-04 | PASS |
| R03 SC-05 | TARGET_ALREADY_CLOSED | Section 10, SC-05 (accepts both `complete` and `done`) | PASS |
| R03 SC-06 | TARGET_IS_LEGACY | Section 10, SC-06 | PASS |
| R03 SC-07 | OUTPUT_ALREADY_EXISTS | Section 10, SC-07 | PASS |
| R03 SC-08 | SOURCE_RANGE_VIOLATION | Section 10, SC-08 | PASS |
| R03 SC-09 | OUTPUT_PATH_OUT_OF_BOUNDS | Section 10, SC-09 | PASS |

### Failure Modes

| Spec | Failure Mode | SKILL.md Location | Verified |
|---|---|---|---|
| R03 FM-01 | SESSION_ID_ABSENT | Section 11, FM-01 SESSION_ID_ABSENT | PASS |
| R03 FM-02 | MISSING_UNIVERSAL_INPUT | Covered by SC-02 (pre-execution). SKILL FM-02 = DISCRIMINATOR_MISMATCH (runtime) | WARN (GA-02) |
| R03 FM-03 | INVALID_OPERATION_TYPE | Covered by SC-01 (pre-execution). SKILL FM-03 = TIMESTAMP_DRIFT (runtime) | WARN (GA-02) |
| R03 FM-04 | TARGET_NOT_FOUND | Covered by SC-04 (pre-execution). SKILL FM-04 = HISTORY_ORDER_VIOLATION (runtime) | WARN (GA-02) |
| R03 FM-05 | TARGET_ALREADY_CLOSED | Covered by SC-05 (pre-execution). SKILL FM-05 = SECTION_MISMATCH (runtime) | WARN (GA-02) |
| R03 FM-06 | TARGET_IS_LEGACY | Section 11, FM-06 TARGET_IS_LEGACY | PASS |
| R03 FM-07 | OUTPUT_ALREADY_EXISTS | Section 11, FM-07 DUPLICATE_SESSION_DOC | PASS |
| R03 FM-08 | WRITE_SURFACE_VIOLATION | Section 11, FM-08 WRITE_SURFACE_VIOLATION | PASS |
| R03 FM-09 | CLEAN_STATE_BLOCKED | Section 11, FM-09 CLEAN_STATE_BLOCKED | PASS |
| R03 FM-10 | PLACEHOLDER_DETECTED | Section 11, FM-10 PLACEHOLDER_DETECTED | PASS |
| R03 FM-11 | STALE_PATH_DETECTED | Section 11, FM-11 STALE_PATH_DETECTED | PASS |
| R03 FM-12 | SOURCE_RANGE_VIOLATION | Covered by SC-08 (pre-execution). SKILL FM-12 = TEMPLATE_READ_FAILURE (runtime) | WARN (GA-02) |
| R03 FM-13 | OUTPUT_PATH_OUT_OF_BOUNDS | Covered by SC-09 (pre-execution). SKILL FM-13 = SOURCE_DOC_UNREADABLE (runtime) | WARN (GA-02) |

### Prohibited Behaviors

| Spec | Behavior | SKILL.md Location | Verified |
|---|---|---|---|
| R03 PB-01 | NO_ID_FABRICATION | Section 12, PB-01 | PASS |
| R03 PB-02 | NO_PARTIAL_CLOSE | Section 12, PB-02 | PASS |
| R03 PB-03 | NO_NW_WRITE | Section 12, PB-03 (scoped for session/report ops, project ops have WS-04..07) | PASS |
| R03 PB-04 | NO_OVERWRITE | Section 12, PB-09 NO_OVERWRITE | PASS |
| R03 PB-05 | NO_DIRTY_ARTIFACT | Section 12, PB-04 NO_DIRTY_ARTIFACT | PASS |
| R03 PB-06 | NO_ROUND_JUMP | Not explicit PB. Covered by Scope section ("documentation only") | WARN (GA-04) |
| R03 PB-07 | NO_LEGACY_TOUCH | Section 12, PB-07 NO_LEGACY_MODIFICATION | PASS |
| R03 PB-08 | NO_VCS_OPERATION | Section 12, PB-05 NO_VCS_OPERATION | PASS |
| R03 PB-09 | NO_SELF_CERTIFY | Not explicit PB. Covered by DH-10 CLEAN_STATE_ITEMIZED | WARN (GA-04) |
| R03 PB-10 | NO_SCOPE_EXPANSION | Section 12, PB-11 NO_SCOPE_CREEP | PASS |
| R03 PB-11 | NO_SILENT_ABORT | Section 12, PB-06 NO_SILENT_ABORT | PASS |
| R03 PB-12 | NO_UNBOUNDED_READ | Not explicit PB. Covered by RS surface boundaries (Section 14) | WARN (GA-04) |

### Documentation Hygiene Rules

| Spec | Rule | SKILL.md Location | Verified |
|---|---|---|---|
| R03 DH-01 | EVIDENCE_BLOCK_REQUIRED | Section 13, DH-01 EVIDENCE_REQUIRED | PASS |
| R03 DH-02 | TIMESTAMP_COHERENCE | Section 13, DH-02 TIMESTAMP_COHERENCE | PASS |
| R03 DH-03 | HISTORY_PREPEND | Section 13, DH-03 HISTORY_PREPEND | PASS |
| R03 DH-04 | CANONICAL_DISCRIMINATOR | Section 13, DH-04 CANONICAL_DISCRIMINATOR | PASS |
| R03 DH-05 | NO_STALE_PATHS | Section 13, DH-05 NO_STALE_PATHS | PASS |
| R03 DH-06 | NO_PLACEHOLDERS | Section 13, DH-06 NO_PLACEHOLDERS | PASS |
| R03 DH-07 | DDI_EMAIL_ALIAS | Section 13, DH-07 ALIAS_IN_FILENAME | PASS |
| R03 DH-08 | COMMIT_HASH_REQUIRED | Section 13, DH-08 COMMIT_HASH_RECORDED | PASS |
| R03 DH-09 | TEMP_ARTIFACT_ACCOUNTING | Section 13, DH-09 TEMP_ARTIFACTS_ACCOUNTED | PASS |
| R03 DH-10 | CLEAN_STATE_EVIDENCE | Section 13, DH-10 CLEAN_STATE_ITEMIZED | PASS |

---

## Round 04 — Publication Gate Plan

| Spec | Requirement | SKILL.md Location | Verified |
|---|---|---|---|
| R04 G-01..G-03 | Three sequential gates defined | External governance — not embedded in skill (correct) | PASS |
| R04 PG-01..PG-05 | Pre-prototype validation checks | External governance — skill is the output of passing these | PASS |
| R04 PP-01..PP-08 | Pre-publish validation checks | External governance — applies at G-03 | PASS |
| R04 NR-01..NR-10 | Not-ready-for-publish conditions | External governance — blocking conditions for publication | PASS |

---

## Round 05 — Project Governance Contract

### New Operations

| Spec | Requirement | SKILL.md Location | Verified |
|---|---|---|---|
| R05 OP-1 | create-project | Section 6 | PASS |
| R05 OP-2 | update-project-status | Section 7 | PASS |
| R05 OP-3 | register-decision | Section 8 | PASS |
| R05 OP-4 | update-next-step | Section 9 | PASS |

### New Inputs (I-50..I-83)

| Spec | Input | SKILL.md Location | Verified |
|---|---|---|---|
| R05 I-50 | `project_name` | Section 6 Additional Inputs | PASS |
| R05 I-51 | `project_type` | Section 6 Additional Inputs | PASS |
| R05 I-52 | `objective` | Section 6 Additional Inputs | PASS |
| R05 I-53 | `initial_phase` | Section 6 Additional Inputs | PASS |
| R05 I-54 | `timestamp_local` | Section 1, I-05 (universal) | PASS |
| R05 I-60 | `project_path` | Section 7 Additional Inputs | PASS |
| R05 I-61 | `section` | Section 7 Additional Inputs | PASS |
| R05 I-62 | `content` | Section 7 Additional Inputs | PASS |
| R05 I-63 | `overall_progress` (optional) | Section 7 Additional Inputs | PASS |
| R05 I-64 | `timestamp_local` | Section 1, I-05 (universal) | PASS |
| R05 I-70 | `project_path` | Section 8 Additional Inputs | PASS |
| R05 I-71 | `decision` | Section 8 Additional Inputs | PASS |
| R05 I-72 | `reason` | Section 8 Additional Inputs | PASS |
| R05 I-73 | `impact` | Section 8 Additional Inputs | PASS |
| R05 I-74 | `decision_date` | Section 8 Additional Inputs | PASS |
| R05 I-80 | `project_path` | Section 9 Additional Inputs | PASS |
| R05 I-81 | `immediate_action` | Section 9 Additional Inputs | PASS |
| R05 I-82 | `required_reading` (optional) | Section 9 Additional Inputs | PASS |
| R05 I-83 | `completion_criteria` (optional) | Section 9 Additional Inputs | PASS |

### New Outputs (O-50..O-82)

| Spec | Output | SKILL.md Location | Verified |
|---|---|---|---|
| R05 O-50 | New folder structure | Section 6 Outputs | PASS |
| R05 O-51 | 5 operational documents | Section 6 Outputs | PASS |
| R05 O-52 | Validation summary (create-project) | Section 6 Evidence block | PASS |
| R05 O-60 | Updated `status-atual.md` | Section 7 Outputs | PASS |
| R05 O-61 | Updated `Last Update` | Section 7 Outputs | PASS |
| R05 O-62 | Validation summary (update-project-status) | Section 7 Evidence block | PASS |
| R05 O-70 | Updated `decisoes.md` | Section 8 Outputs | PASS |
| R05 O-71 | Decision entry format | Section 8 Outputs + step 5 | PASS |
| R05 O-72 | Validation summary (register-decision) | Section 8 Evidence block | PASS |
| R05 O-80 | Updated `next-step.md` | Section 9 Outputs | PASS |
| R05 O-81 | Conditional updates | Section 9 Outputs + steps 5-7 | PASS |
| R05 O-82 | Validation summary (update-next-step) | Section 9 Evidence block | PASS |

### Extended Skip Conditions

| Spec | Condition | SKILL.md Location | Verified |
|---|---|---|---|
| R05 SC-10 | PROJECT_PATH_INVALID | Section 10, SC-10 | PASS |
| R05 SC-11 | PROJECT_ALREADY_EXISTS | Section 10, SC-11 | PASS |
| R05 SC-12 | MISSING_PROJECT_INPUT | Section 10, SC-12 | PASS |

### Extended Failure Modes

| Spec | Failure Mode | SKILL.md Location | Verified |
|---|---|---|---|
| R05 FM-14 | PROJECT_STRUCTURE_INCOMPLETE | Section 11, FM-14 | PASS |
| R05 FM-15 | PROJECT_DOC_NOT_FOUND | Section 11, FM-15 | PASS |
| R05 FM-16 | PROJECT_STATUS_SECTION_INVALID | Section 11, FM-16 | PASS |

### Extended Prohibited Behaviors

| Spec | Behavior | SKILL.md Location | Verified |
|---|---|---|---|
| R05 PB-13 | NO_PROJECT_DECISION_FABRICATION | Section 12, PB-13 | PASS |
| R05 PB-14 | NO_PROJECT_OVERWRITE | Section 12, PB-14 | PASS |
| R05 PB-15 | NO_CROSS_PROJECT_WRITE | Section 12, PB-15 | PASS |

### Extended Hygiene Rules

| Spec | Rule | SKILL.md Location | Verified |
|---|---|---|---|
| R05 DH-11 | DECISION_FORMAT | Section 13, DH-11 | PASS |
| R05 DH-12 | STATUS_DATE | Section 13, DH-12 | PASS |
| R05 DH-13 | PROJECT_WIKILINKS | Section 13, DH-13 | PASS |

### Extended Read/Write Surfaces

| Spec | Surface | SKILL.md Location | Verified |
|---|---|---|---|
| R05 RS-06 | `projects/_templates/*.md` | Section 14, RS-06 | PASS |
| R05 RS-07 | `projects/skills/{project}/PROJECT_CONTEXT.md` | Section 14, RS-07 | PASS |
| R05 RS-08 | `projects/{project}/PROJECT_CONTEXT.md` | Section 14, RS-08 | PASS |
| R05 RS-09 | `projects/skills/{project}/status-atual.md` | Section 14, RS-09 | PASS |
| R05 RS-10 | `projects/skills/{project}/decisoes.md` | Section 14, RS-10 | PASS |
| R05 RS-11 | `projects/skills/{project}/next-step.md` | Section 14, RS-11 | PASS |
| R05 RS-12 | `projects/{project}/status-atual.md` | Section 14, RS-12 | PASS |
| R05 RS-13 | `projects/{project}/decisoes.md` | Section 14, RS-13 | PASS |
| R05 RS-14 | `projects/{project}/next-step.md` | Section 14, RS-14 | PASS |
| R05 WS-04 | `projects/skills/{project}/*.md` | Section 14, WS-04 | PASS |
| R05 WS-05 | `projects/skills/{project}/*/` | Section 14, WS-05 | PASS |
| R05 WS-06 | `projects/{project}/*.md` | Section 14, WS-06 | PASS |
| R05 WS-07 | `projects/{project}/*/` | Section 14, WS-07 | PASS |

### Other Round 05 Requirements

| Spec | Requirement | SKILL.md Location | Verified |
|---|---|---|---|
| R05 Folder structure (skill) | Skill project subfolder list | Section 6 step 4 (skill projects) | PASS |
| R05 Folder structure (general) | General project subfolder list | Section 6 step 4 (general projects) | PASS |
| R05 NW interaction | NW-04..NW-06 scoping for project ops | Section 14 NW-02..NW-04 notes, PB-03 note | PASS |
| R05 Operation routing | Constraint routing by operation type | Implicit in operation sections (each lists its own SCs) | PASS |
| R05 Standard Status Summary | Fixed 7-field format with data sources | Section 16 + PROJECT_CONTEXT.md template (Section 15.3.1) | PASS |

---

## Integration Test Findings (PT-R4)

| Finding | Requirement | SKILL.md Fix Location | Verified |
|---|---|---|---|
| F-01 | Accept both `done` and `complete` as closed | Section 4 note (line 278), step 3 (lines 297-298) | PASS |
| F-02 | Backward-compat folder names note | Section 6 step 4 note (lines 439-445) | PASS |
| F-03 | SC-05 accepts both `done` and `complete` | Section 10, SC-05 (line 684) | PASS |
