---
name: daily-doc-information
description: Automates creation, update, closure of session docs and daily reports, plus project governance operations (create-project, update-project-status, register-decision, update-next-step, update-portfolio) with identity, hygiene, and gate enforcement
command: /daily-doc-information
version: 1.7.1
category: Documentation Automation
trigger: When user invokes /daily-doc-information or asks to create/update/close session docs, create daily reports, or perform project governance operations (create/update projects, register decisions, update next steps)
tags:
  - documentation
  - session-management
  - daily-reports
  - project-governance
  - automation
---

# daily-doc-information

**Version:** 1.7.1

> **Objective:** Automates the creation, structured update, and clean-state closure of session documents and daily reports, plus project governance operations (project creation, status updates, decision registration, next-step management) according to the continuity-documentation contract.

## Scope

This skill governs **documentation only**. It does NOT:
- Make project decisions
- Execute code implementations
- Perform git operations (commits, pushes, branches)
- Modify project configuration files

## Quick Reference

| Operation | Purpose | Key Output |
|---|---|---|
| `create-session` | Create a new session document from template | New session `.md` in `ai-sessions/YYYY-MM/` |
| `update-session` | Add structured content to an open session doc | Updated session `.md` with new rows/fields |
| `close-session` | Validate clean-state and close a session doc | Closed session `.md` with `status: complete` |
| `create-daily-report` | Consolidate session docs into a daily report | New daily report `.md` in `daily-reports/YYYY-MM/` |
| `create-project` | Create a new formal project with folder structure and docs | New project folder with 5 operational docs |
| `update-project-status` | Update project status-atual.md | Updated status doc |
| `register-decision` | Add decision to project decisoes.md | Updated decision log |
| `update-next-step` | Update project next-step.md | Updated next step doc |
| `update-portfolio` | Update Strategic Project Portfolio | Updated `strategic-project-portfolio.md` |

---

## Cross-Agent Compatibility

This skill is designed to work with **any LLM agent** that can read markdown and perform filesystem operations. It is NOT tied to any specific provider or tool.

**Compatibility guarantee:**
- All operations are defined as structured instructions, not code tied to a specific runtime
- No operation depends on proprietary APIs, tools, or CLI commands
- Any agent that can read files, write files, and follow structured instructions can execute this skill
- The skill uses standard markdown format readable by all major LLMs

**Tested/compatible providers:**
| Provider | Agent | CLI | Notes |
|---|---|---|---|
| Anthropic | Claude Code (Sonnet/Opus) | `claude` | Primary development agent |
| OpenAI | Codex (via CLI) | `codex` | Audit and strategy roles |
| Google | Gemini (via CLI) | `gemini` | Validated in cross-LLM tests |
| Any other | Any LLM with file I/O | N/A | Must be able to read/write markdown files |

**Agent-specific adaptation:**
Each agent adapts the filesystem operations to its own tooling:
- Claude Code: uses `Read`, `Write`, `Edit` tools
- Codex: uses file operation tools or shell commands
- Gemini: uses file read/write tools
- Other agents: use whatever filesystem tools are available

The skill instructions say "read file X" and "write file Y" — the agent translates these to its own tools.

---

## Environment Configuration

This skill uses a **configurable base path** for all file operations. The default base path is `C:\ai\` (Windows) or `/c/ai/` (Git Bash/WSL).

**Path structure relative to base path:**

| Path | Purpose | Example with default base |
|---|---|---|
| `{BASE}\obsidian\CIH\projects\` | Documental layer — project documentation | `C:\ai\obsidian\CIH\projects\` |
| `{BASE}\obsidian\CIH\projects\skills\` | Skill project documentation | `C:\ai\obsidian\CIH\projects\skills\` |
| `{BASE}\_skills\` | Technical layer — code, scripts, tests | `C:\ai\_skills\` |
| `{BASE}\claude-intelligence-hub\` | Publication layer — published skills | `C:\ai\claude-intelligence-hub\` |

**Configuration rules:**
1. The base path `{BASE}` is the same on all machines belonging to the same owner
2. The owner is responsible for ensuring `{BASE}` exists and is consistent across machines
3. All paths in this skill are relative to `{BASE}` — never hardcoded to a specific machine
4. User-specific paths (like `C:\Users\{username}\`) are NEVER part of the skill's path structure
5. If a new user adopts this skill with a different base path, they must update `{BASE}` in their configuration

**Machine portability:**
- The base path default (`C:\ai\`) is a convention, not a requirement
- All subpaths below `{BASE}` are identical across machines
- The skill never reads or writes paths outside `{BASE}` (except for the skill file itself, which lives in the agent's skill directory)
- Machine-specific values (hostname, OS user, timezone) are captured at runtime via universal inputs, never hardcoded

**For new users/machines:**
If your base path is not `C:\ai\`, update the path references accordingly. The internal structure (`obsidian\CIH\projects\`, `_skills\`, etc.) must remain the same.

---

## 1. Universal Inputs

These inputs are **required for ALL operations**. If any is absent or empty, fire SC-02.

| ID | Input | Type | Notes |
|---|---|---|---|
| I-01 | `operation` | string | One of: `create-session`, `update-session`, `close-session`, `create-daily-report`, `create-project`, `update-project-status`, `register-decision`, `update-next-step`, `update-portfolio` |
| I-02 | `agent_name` | string | Name of the invoking agent (e.g., `Magneto`) |
| I-03 | `agent_slug` | string | Lowercase form (e.g., `magneto`) |
| I-04 | `machine_id` | string | Hostname from real environment |
| I-05 | `timestamp_local` | string | Current machine timestamp `YYYY-MM-DD HH:MM` from real clock |
| I-06 | `timezone` | string | IANA timezone (e.g., `America/Sao_Paulo`) |
| I-07 | `llm_model` | string | Specific LLM model ID that opened the session (e.g., `claude-opus-4-6`, `claude-sonnet-4-6`, `gemini-2.5-pro`) |

---

## 2. Operation: create-session

### What it does
Creates a new session document from the embedded template, populating all placeholders with actual values and establishing the canonical discriminator.

### Additional Inputs

| Input | Type | Notes |
|---|---|---|
| `session_id` | string | Full UUID — MUST be provided externally, NEVER fabricated by agent |
| `session_id_short` | string | First 8 characters of `session_id` |
| `project` | string | Project identifier (e.g., `daily-doc-information`) |
| `context_type` | string | `Project` or `General` |
| `session_name` | string | Human-readable name for the session |
| `output_path` | string | Absolute path where new doc goes, must be inside `ai-sessions/YYYY-MM/` |

### Outputs
- New session document at `output_path` with all frontmatter and body populated
- Validation summary confirming canonical discriminator present, all fields non-empty, path correct

### Filename Pattern
```
session-[session_id_short]-[YYYY-MM-DD]-[agent_slug].md
```

### Execution Steps

1. **Fire skip conditions:** Verify SC-01, SC-02, SC-03, SC-07, SC-09. If any fires, abort immediately with the skip condition ID and description.
2. **Resolve template:** Use the embedded session doc template from Section 15 of this skill.
3. **Compute canonical discriminator:** `[session_id_short]-[machine_id]-[agent_slug]-[YYYY-MM-DD]`
4. **Replace ALL template placeholders** with actual values:
   - `{{SESSION_ID}}` → `session_id`
   - `{{SESSION_ID_SHORT}}` → `session_id_short`
   - `{{AGENT_NAME}}` → `agent_name`
   - `{{AGENT_SLUG}}` → `agent_slug`
   - `{{AGENT_LABEL}}` → `agent_name (agent_slug)`
   - `{{PROVIDER}}` → Provider name (e.g., `Anthropic`)
   - `{{LLM_MODEL}}` → `llm_model`
   - `{{MACHINE_NAME}}` → `machine_id`
   - `{{OS_USER}}` → Current OS user
   - `{{YYYY-MM-DD}}` → Date from `timestamp_local`
   - `{{HH:MM}}` → Time from `timestamp_local`
   - `{{SESSION_NAME}}` → `session_name`
   - `{{CONTEXT_TYPE}}` → `context_type`
   - `{{PROJECT}}` → `project`
   - `{{PROJECT_TAG}}` → Lowercase, hyphenated project tag
   - `{{TIME_OF_DAY}}` → Macro period: `morning`, `afternoon`, `evening`, or `late-night`
   - `{{DAY_TYPE}}` → `weekday` or `weekend`
   - `{{MAIN_SUBJECT}}` → Derived from session_name or project
   - `{{SUBJECT_1}}` → First secondary subject or `documentation`
   - `{{BLOCK_TITLE}}` → First block title from session_name
   - `{{PREVIOUS_SESSION}}` → Link to previous session or `N/A`
   - `{{TARGET_FILE}}` → Target file/prompt or `N/A`
5. **Set frontmatter fields:**
   - `session_key` → canonical discriminator
   - `status` → `in_progress`
   - `opened_at_local` → `timestamp_local`
   - `last_updated_at_local` → `timestamp_local`
   - `closed_at_local` → `pending`
6. **Verify output_path does NOT already exist.** If it does, fire SC-07.
7. **Write the populated document** to `output_path`.
8. **Produce validation evidence block:**

```
=== EVIDENCE: create-session ===
Operation: create-session
Timestamp: [timestamp_local]
Agent: [agent_name] ([agent_slug])
Machine: [machine_id]
Session ID: [session_id]
Session ID Short: [session_id_short]
Canonical Discriminator: [discriminator]
Output Path: [output_path]
Checks:
  - Canonical discriminator present in frontmatter: YES/NO
  - Canonical discriminator present in body: YES/NO
  - All frontmatter fields non-empty: YES/NO
  - Output path inside ai-sessions/YYYY-MM/: YES/NO
  - Filename matches pattern: YES/NO
  - No residual placeholders: YES/NO
Result: PASS / FAIL
=== END EVIDENCE ===
```

---

## 3. Operation: update-session

### What it does
Adds structured content to a specific section of an existing, open session document.

### Additional Inputs

| Input | Type | Notes |
|---|---|---|
| `target_path` | string | Absolute path to existing open session doc |
| `update_type` | string | One of: `history`, `decision`, `validation`, `next_action`, `block_status` |
| `update_content` | string/object | Structured content to add — must be non-empty, no placeholders |

### Outputs
- Updated session document with new content in the correct section
- `last_updated_at_local` updated in both frontmatter and body (must match)
- Validation summary

### Execution Steps

1. **Fire skip conditions:** Verify SC-01, SC-02, SC-04, SC-05, SC-06. If any fires, abort immediately.
2. **Read existing document** at `target_path`.
3. **Verify status** is `in_progress` or `pre_open`. If `complete` or `done`, fire SC-05.
4. **Add content to the correct section** based on `update_type`:

| update_type | Target Section | Placement Rule |
|---|---|---|
| `history` | Modification History table | **Prepend** new row at TOP (newest first, per DH-03) |
| `decision` | Decisions table in current block | **Append** new row at bottom of table |
| `validation` | Validations table in current block | **Append** new row at bottom of table |
| `next_action` | Next action in Current Snapshot AND current block | **Replace** existing value |
| `block_status` | Status in current block AND Work Blocks table | **Replace** existing value |

5. **Update `last_updated_at_local`** in BOTH frontmatter AND body header to current `timestamp_local`. Both values MUST match (DH-02).
6. **Verify no stale paths or placeholders** were introduced (DH-05, DH-06).
7. **Write updated document** back to `target_path`.
8. **Produce validation evidence block:**

```
=== EVIDENCE: update-session ===
Operation: update-session
Timestamp: [timestamp_local]
Agent: [agent_name] ([agent_slug])
Machine: [machine_id]
Target Path: [target_path]
Update Type: [update_type]
Checks:
  - Target exists: YES/NO
  - Target status is open: YES/NO
  - Content added to correct section: YES/NO
  - last_updated_at_local frontmatter matches body: YES/NO
  - No stale paths introduced: YES/NO
  - No placeholders introduced: YES/NO
Result: PASS / FAIL
=== END EVIDENCE ===
```

---

## 4. Operation: close-session

### What it does
Validates all 7 clean-state criteria and, if all pass, closes the session document with final status and timestamp.

### Additional Inputs

| Input | Type | Notes |
|---|---|---|
| `target_path` | string | Absolute path to session doc to close |
| `clean_state_evidence` | object | Explicit evidence for all 7 criteria (see below) |

### Outputs
- Gate result: `PASS` or `BLOCKED` with itemized criteria results
- If `PASS`: Closed session doc with `status: complete`, `closed_at_local` set, final history row
- Closure evidence block

> **Note on closed status values:** New documents use `status: complete`. Existing documents with `status: done` are recognized as closed.

### Clean-State Criteria

All 8 criteria MUST pass. If ANY is `BLOCKED`, return gate result with failing criteria and **STOP — do NOT modify the document**.

| ID | Criterion | Requirement |
|---|---|---|
| CS-01 | `next_action` is single and explicit | Not empty, not a list of alternatives, not `pending` |
| CS-02 | `blockers` are declared | At least one blocker listed OR explicit "no blockers" / "nenhum bloqueio" |
| CS-03 | At least one decision recorded | Current block has at least one row in Decisions table |
| CS-04 | At least one validation recorded with result | Current block has at least one row in Validations table with a result value |
| CS-05 | Temporary artifacts accounted for | All temp artifacts committed, discarded, or deferred with justification |
| CS-06 | Commit/push justification stated | If changes were made: commit hash recorded; if no changes: explicit statement |
| CS-07 | `project docs synchronized` | If the session doc references any project (`context_type: Project`), the project's `status-atual.md`, `next-step.md`, and `decisoes.md` must reflect the work performed in this session. The agent must verify that project progress, decisions, and next steps recorded in the session blocks are also recorded in the project operational docs. If any referenced project's docs are stale relative to the session content, the gate is BLOCKED. |
| CS-08 | `findings reconciled` | If `has_findings: true`, all findings in the session doc must also be registered in `C:\ai\obsidian\CIH\projects\_findings\findings-master-index.md`. For project closure sessions: sweep ALL session docs of the project, collect all findings, and verify each appears in the master index. Any unreconciled finding blocks closure. This is non-negotiable. |

### Execution Steps

1. **Fire skip conditions:** Verify SC-01, SC-02, SC-04, SC-05, SC-06. If any fires, abort immediately.
2. **Read existing document** at `target_path`.
3. **Verify status** is `in_progress` or `pre_open`. If `complete` or `done`, fire SC-05.
   > **Note:** The canonical closed status is `complete`. For backward compatibility with pre-skill documents that use `done`, both values are treated as equivalent closed states.
4. **Evaluate all 8 clean-state criteria** against the document content and `clean_state_evidence`:
   - For each criterion, record `PASS` or `BLOCKED` with specific evidence.
5. **If ANY criterion is BLOCKED:**
   - Return gate result with all 7 criteria itemized (showing which passed and which failed).
   - Fire FM-09 (CLEAN_STATE_BLOCKED).
   - **STOP. Do NOT modify the document.**
6. **If ALL criteria PASS:**
   - Set `status` to `complete` in frontmatter.
   - Set `closed_at_local` to `timestamp_local` in frontmatter AND body.
   - Update `last_updated_at_local` to `timestamp_local` in frontmatter AND body.
   - Prepend final history row: `[date] | [period] | [time] | [tz] | [agent] | [machine] | Session closure. Clean-state gate: PASS.`
   - Update Current Snapshot: `Overall status` → `complete`, `Clean-state gate` → `PASS`.
   - Update Handoff section with final values.
7. **Produce closure evidence block:**

```
=== EVIDENCE: close-session ===
Operation: close-session
Timestamp: [timestamp_local]
Agent: [agent_name] ([agent_slug])
Machine: [machine_id]
Target Path: [target_path]
Gate Result: PASS / BLOCKED
Criteria:
  CS-01 next_action explicit: PASS/BLOCKED — [evidence]
  CS-02 blockers declared: PASS/BLOCKED — [evidence]
  CS-03 decision recorded: PASS/BLOCKED — [evidence]
  CS-04 validation recorded: PASS/BLOCKED — [evidence]
  CS-05 temp artifacts accounted: PASS/BLOCKED — [evidence]
  CS-06 commit justification stated: PASS/BLOCKED — [evidence]
  CS-07 project docs synchronized: PASS/BLOCKED — [evidence]
Actions Taken:
  - status set to complete: YES/NO
  - closed_at_local set: YES/NO
  - final history row added: YES/NO
  - Current Snapshot updated: YES/NO
Result: PASS / BLOCKED
=== END EVIDENCE ===
```

---

## 5. Operation: create-daily-report

### What it does
Consolidates one or more session documents into a daily executive report using the embedded template.

### Additional Inputs

| Input | Type | Notes |
|---|---|---|
| `report_date` | string | `YYYY-MM-DD` format |
| `source_session_docs` | list | List of absolute paths to session docs to consolidate |
| `output_path` | string | Absolute path, must be inside `daily-reports/YYYY-MM/` (monthly subfolder, consistent with `ai-sessions/YYYY-MM/`) |

### Outputs
- New daily report at `output_path` populated from source session docs
- Validation summary

### Filename Pattern
```
daily-report-executive-[YYYY-MM-DD]-v1.md
```

> **Monthly subfolder convention:** Daily reports are stored in `daily-reports/YYYY-MM/` subfolders (e.g., `daily-reports/2026-03/`), consistent with the `ai-sessions/YYYY-MM/` convention. The agent must create the `YYYY-MM/` subfolder if it does not exist before writing the report.

### Execution Steps

1. **Fire skip conditions:** Verify SC-01, SC-02, SC-07, SC-08, SC-09. If any fires, abort immediately.
2. **Verify all source docs are in active range** (2026-03-13 or later). If any is earlier, fire SC-08 for that doc.
3. **Resolve template:** Use the embedded daily report template from Section 15 of this skill.
4. **Read each source session doc** from `source_session_docs`.
5. **Extract from each source doc:**
   - Projects worked on (from `project` frontmatter and block context_type)
   - Key actions (from Modification History and block content)
   - Decisions (from Decisions tables)
   - Blockers (from Current Snapshot and block content)
   - Session metadata (session_id, agent, project, status)
6. **Populate template sections:**
   - **Frontmatter:** Fill all fields — `agents`, `sessions_covered`, `total_sessions`, dates, author.
   - **Current Snapshot:** Summarize project work and general work.
   - **Project Work:** Group actions by project. For each project, fill Key Actions, Progress, Major Decisions, Blockers.
   - **General Work:** Group non-project actions by theme.
   - **Sessoes Oficiais Vinculadas:** One row per source session doc with Session ID, Agent, Project, Status.
7. **Verify output_path does NOT already exist.** If it does, fire SC-07.
8. **Write the populated report** to `output_path`.
9. **Produce validation evidence block:**

```
=== EVIDENCE: create-daily-report ===
Operation: create-daily-report
Timestamp: [timestamp_local]
Agent: [agent_name] ([agent_slug])
Machine: [machine_id]
Report Date: [report_date]
Source Docs: [count] documents
Output Path: [output_path]
Checks:
  - All source docs in active range: YES/NO
  - All source docs readable: YES/NO
  - Output path inside daily-reports/YYYY-MM/: YES/NO
  - Filename matches pattern: YES/NO
  - No residual placeholders: YES/NO
  - Sessions table complete: YES/NO
Result: PASS / FAIL
=== END EVIDENCE ===
```

---

## 6. Operation: create-project

### What it does
Creates a new formal project with full folder structure and 5 operational documents from embedded templates.

### Additional Inputs

| Input | Type | Notes |
|---|---|---|
| `project_name` | string | Project identifier (e.g., `daily-doc-information`). Used for folder name and template substitution. |
| `project_type` | string | One of: `skill`, `general`. Determines target root: `projects/skills/` or `projects/`. |
| `objective` | string | One-line project objective. Populates `PROJECT_CONTEXT.md` and the initial decision entry. |
| `initial_phase` | string | Starting phase name (e.g., `Kickoff`, `Planning`, `Round 01`). Populates `Current Phase` in templates. |

### Outputs
- New folder structure at the correct location based on `project_type`
- 5 operational docs created from templates: `PROJECT_CONTEXT.md`, `status-atual.md`, `next-step.md`, `decisoes.md`, `README.md`
- All template variables fully substituted
- Validation summary

### Execution Steps

1. **Fire skip conditions:** Verify SC-01, SC-02, SC-11, SC-12. If any fires, abort immediately with the skip condition ID and description.
2. **Determine target path** based on `project_type`:
   - `skill` → `projects/skills/{project_name}/`
   - `general` → `projects/{project_name}/`
3. **Verify target folder does NOT exist.** If it does, fire SC-11 (PROJECT_ALREADY_EXISTS). Abort immediately.
4. **Create folder structure:**
   - **For ALL projects:** `00_prompts_agents/`, `01-manifesto-contract/`, `02-planning/`, `04-tests/`, `05-final/`, `06-operationalization/`
   - **For skill projects, also create:** `03-spec/`, `07-templates/`, `ai-sessions/YYYY-MM/` (using year-month from `timestamp_local`), `daily-reports/`
   - **For general projects, also create:** `03-reviews/`
   - Note: Skill projects use `05-audits/` instead of `05-final/`.

**Backward compatibility:** Projects created before this skill may use different folder names:
- `00-prompts` instead of `00_prompts_agents`
- `05-audits` instead of `05-final`
- `06-final` instead of `06-operationalization`
- `03-spec` instead of `03-reviews` (for skill projects)

The canonical names for NEW projects are as specified above. The skill does not rename existing folders.

5. **Create 5 operational docs** from embedded templates (Section 15.3):
   - `PROJECT_CONTEXT.md`
   - `status-atual.md`
   - `next-step.md`
   - `decisoes.md`
   - `README.md`
5a. **Create project notes file** from embedded template (Section 15.4):
   - Target folder: `00_prompts_agents/` (or `00-prompts/` if using that convention)
   - Filename: `ddi-pjt-gi-notes-ans-jimmy-orquestrator.md` (substitute `jimmy` and `orquestrator` with actual owner/orchestrator roles if different)
   - Replace `{{PROJECT_NAME}}` and `{{YYYY-MM-DD}}` with actual values
   - This file is the permanent record for all threads, discussions, and Q&A that do not belong in session docs or planning docs
6. **Replace ALL template placeholders** with actual values:
   - `{{PROJECT_NAME}}` → `project_name`
   - `{{PROJECT_OBJECTIVE}}` → `objective`
   - `{{CURRENT_PHASE}}` → `initial_phase`
   - `{{YYYY-MM-DD}}` → Date from `timestamp_local`
   - `{{IN_PROGRESS_ITEM_1}}` → `"Project kickoff and initial structure"`
   - `{{INITIAL_PROGRESS}}` → `"Project formally opened. Initial structure created."`
   - `{{IMMEDIATE_ACTION}}` → `"Read PROJECT_CONTEXT.md and confirm project scope with Jimmy."`
   - `{{COMPLETION_CRITERIA}}` → `"Jimmy has confirmed the project scope and objective."`
   - `{{CORE_DOC_1}}` → `PROJECT_CONTEXT.md`
   - `{{CORE_DOC_2}}` → `status-atual.md`
7. **Verify no residual placeholders** in any of the 5 docs (`{{...}}`, `TODO`, `TBD`).
8. **Verify all 5 docs have wikilinks** connecting them to each other and to `[[projects]]` (DH-13).
9. **If any folder or file creation failed**, fire FM-14 (PROJECT_STRUCTURE_INCOMPLETE). Return list of what failed. Do not leave partial structure without reporting.
10. **Produce validation evidence block:**

```
=== EVIDENCE: create-project ===
Operation: create-project
Timestamp: [timestamp_local]
Agent: [agent_name] ([agent_slug])
Machine: [machine_id]
Project Name: [project_name]
Project Type: [project_type]
Target Path: [target_path]
Checks:
  - Target folder did not exist before: YES/NO
  - All subfolders created: YES/NO ([count]/[expected])
  - All 5 operational docs created: YES/NO
  - Project notes file created in 00_prompts_agents/: YES/NO
  - No residual placeholders: YES/NO
  - Wikilinks present in all docs: YES/NO
  - Folder structure matches project_type: YES/NO
Result: PASS / FAIL
=== END EVIDENCE ===
```

---

## 7. Operation: update-project-status

### What it does
Updates the `status-atual.md` file with new items in the appropriate section and refreshes the `Last Update` date.

### Additional Inputs

| Input | Type | Notes |
|---|---|---|
| `project_path` | path | Absolute path to the project root folder. Must contain `PROJECT_CONTEXT.md`. |
| `section` | string | One of: `completed`, `in_progress`, `blocked`. Determines which section receives the new item. |
| `content` | string | The item text to add. Must be non-empty and free of placeholders. |
| `overall_progress` | string (optional) | Updated progress description. If absent, existing `Overall Progress` is left unchanged. |

### Outputs
- Updated `status-atual.md` with new item in the correct section
- `Last Update` set to current date
- If `overall_progress` provided, `Overall Progress` updated
- Validation summary

### Execution Steps

1. **Fire skip conditions:** Verify SC-01, SC-02, SC-10, SC-12. If any fires, abort immediately with the skip condition ID and description.
2. **Validate `project_path`:** Verify `PROJECT_CONTEXT.md` exists at `{project_path}/PROJECT_CONTEXT.md`. If not, fire SC-10.
3. **Validate `section`:** Must be one of `completed`, `in_progress`, `blocked`. If not, fire FM-16.
4. **Read existing `status-atual.md`** at `{project_path}/status-atual.md`. If not found, fire FM-15.
5. **Add `content` to the correct section:**
   - `completed` → Add as new bullet under `Completed` section
   - `in_progress` → Add as new bullet under `In Progress` section
   - `blocked` → Add as new bullet under `Blocked` section
6. **Update `Last Update`** to current date from `timestamp_local`.
7. **If `overall_progress` is provided**, update the `Overall Progress` field.
8. **Verify no placeholders** were introduced (DH-06).
9. **Write updated document** back to `{project_path}/status-atual.md`.
10. **Produce validation evidence block:**

```
=== EVIDENCE: update-project-status ===
Operation: update-project-status
Timestamp: [timestamp_local]
Agent: [agent_name] ([agent_slug])
Machine: [machine_id]
Project Path: [project_path]
Section: [section]
Content: [content]
Checks:
  - project_path is valid (PROJECT_CONTEXT.md exists): YES/NO
  - Section is valid: YES/NO
  - Item added to correct section: YES/NO
  - Last Update is current: YES/NO
  - No placeholders introduced: YES/NO
  - Wikilinks preserved: YES/NO
Result: PASS / FAIL
=== END EVIDENCE ===
```

---

## 8. Operation: register-decision

### What it does
Adds a new decision entry to the project's `decisoes.md` file with mandatory Decision/Reason/Impact format.

### Additional Inputs

| Input | Type | Notes |
|---|---|---|
| `project_path` | path | Absolute path to the project root folder. Must contain `PROJECT_CONTEXT.md`. |
| `decision` | string | The decision text. Must be non-empty. |
| `reason` | string | Why this decision was made. Must be non-empty. |
| `impact` | string | What the decision changes. Must be non-empty. |
| `decision_date` | string | Date in `YYYY-MM-DD` format. |

### Outputs
- Updated `decisoes.md` with new decision entry at the TOP (newest first)
- Entry uses mandatory format: `## YYYY-MM-DD` header, `Decision:` line, `Reason:` line, `Impact:` line
- Validation summary

### Execution Steps

1. **Fire skip conditions:** Verify SC-01, SC-02, SC-10, SC-12. If any fires, abort immediately with the skip condition ID and description.
2. **Validate `project_path`:** Verify `PROJECT_CONTEXT.md` exists at `{project_path}/PROJECT_CONTEXT.md`. If not, fire SC-10.
3. **Validate all three fields** (`decision`, `reason`, `impact`) are non-empty. If any is empty, fire SC-12 (DH-11).
4. **Read existing `decisoes.md`** at `{project_path}/decisoes.md`. If not found, fire FM-15.
5. **Add new decision entry at the TOP** (after the `# Decision Log` header, before existing entries — newest first):
   ```
   ## YYYY-MM-DD

   Decision:
   [decision text]

   Reason:
   [reason text]

   Impact:
   [impact text]
   ```
6. **Verify wikilinks** are preserved at the bottom of the file (DH-13).
7. **Verify no placeholders** were introduced (DH-06).
8. **Write updated document** back to `{project_path}/decisoes.md`.
9. **Produce validation evidence block:**

```
=== EVIDENCE: register-decision ===
Operation: register-decision
Timestamp: [timestamp_local]
Agent: [agent_name] ([agent_slug])
Machine: [machine_id]
Project Path: [project_path]
Decision Date: [decision_date]
Checks:
  - project_path is valid (PROJECT_CONTEXT.md exists): YES/NO
  - All three fields non-empty (Decision/Reason/Impact): YES/NO
  - Entry added at TOP (before existing entries): YES/NO
  - No placeholders introduced: YES/NO
  - Wikilinks preserved: YES/NO
Result: PASS / FAIL
=== END EVIDENCE ===
```

---

## 9. Operation: update-next-step

### What it does
Updates the project's `next-step.md` file with a new immediate action and optionally updates required reading and completion criteria.

### Additional Inputs

| Input | Type | Notes |
|---|---|---|
| `project_path` | path | Absolute path to the project root folder. Must contain `PROJECT_CONTEXT.md`. |
| `immediate_action` | string | What to do next. Must be non-empty and specific. |
| `required_reading` | list of strings (optional) | Documents to read before executing. If absent, existing list is preserved. |
| `completion_criteria` | list of strings (optional) | Criteria to check when step is done. If absent, existing list is preserved. |

### Outputs
- Updated `next-step.md` with new `Immediate Action`
- If `required_reading` provided, `Required Reading` list replaced
- If `completion_criteria` provided, `Completion Criteria` replaced
- Validation summary

### Execution Steps

1. **Fire skip conditions:** Verify SC-01, SC-02, SC-10, SC-12. If any fires, abort immediately with the skip condition ID and description.
2. **Validate `project_path`:** Verify `PROJECT_CONTEXT.md` exists at `{project_path}/PROJECT_CONTEXT.md`. If not, fire SC-10.
3. **Read existing `next-step.md`** at `{project_path}/next-step.md`. If not found, fire FM-15.
4. **Replace `Immediate Action`** section content with new `immediate_action` value.
5. **If `required_reading` is provided**, replace the `Required Reading` list with the new list.
6. **If `completion_criteria` is provided**, replace the `Completion Criteria` section with the new list.
7. **If `required_reading` or `completion_criteria` is absent**, preserve the existing content for that section.
8. **Verify no placeholders** were introduced (DH-06).
9. **Verify wikilinks** are preserved at the bottom of the file (DH-13).
10. **Write updated document** back to `{project_path}/next-step.md`.
11. **Produce validation evidence block:**

```
=== EVIDENCE: update-next-step ===
Operation: update-next-step
Timestamp: [timestamp_local]
Agent: [agent_name] ([agent_slug])
Machine: [machine_id]
Project Path: [project_path]
Immediate Action: [immediate_action]
Required Reading Updated: YES/NO
Completion Criteria Updated: YES/NO
Checks:
  - project_path is valid (PROJECT_CONTEXT.md exists): YES/NO
  - Immediate Action is non-empty: YES/NO
  - No placeholders introduced: YES/NO
  - Wikilinks preserved: YES/NO
Result: PASS / FAIL
=== END EVIDENCE ===
```

---

## 10. Operation: update-portfolio

### What it does
Updates the Strategic Project Portfolio (`obsidian/CIH/projects/strategic-project-portfolio.md`) — a single-page executive view of ALL projects with status, priority, next moves, and responsible parties. Readable in under 60 seconds.

### When to trigger
- At every checkpoint (as part of PP-01 validation)
- At every session close (if any project changed status, phase, or priority)
- When a new project is created
- When a project changes phase or status

### Additional Inputs

| Input | Type | Notes |
|---|---|---|
| `portfolio_path` | path | Default: `obsidian/CIH/projects/strategic-project-portfolio.md` |

### Execution Steps

1. **Read current portfolio** at `portfolio_path`.
2. **Scan all project `status-atual.md` files** (both `obsidian/CIH/projects/skills/*/status-atual.md` and `obsidian/CIH/projects/*/status-atual.md`).
3. **Update Project Registry table** — ensure every project has an accurate row with: status, priority, phase, last activity date, next move, responsible party.
4. **Update Portfolio Summary counters** (total, production, active, paused, archived) and frontmatter.
5. **Update Active Projects executive detail** — add or update any project that is Active with a detailed breakdown table.
6. **Update Paused Projects section** — list any project awaiting a decision.
7. **Update Production Projects key stats** — version numbers and key metrics.
8. **Add Timeline entry** for the current date if significant events occurred.
9. **Update `last_updated` and `updated_by`** in frontmatter and body.
10. **Verify wikilinks** — every project mentioned in the registry MUST appear in the Wikilinks section.

### Portfolio Status Definitions

| Status | Meaning |
|---|---|
| Production | Skill published and operational. No active development. |
| Active | Currently being worked on. Has assigned next moves. |
| Paused | Work stopped. Awaiting a decision to resume. |
| Archived | Absorbed into another project or no longer relevant. |

---

## 12. Skip Conditions

Skip conditions fire **BEFORE any work begins**. When a skip condition fires: abort immediately, return the skip condition ID and description. Never silently abort.

| ID | Condition | Description | Applies to |
|---|---|---|---|
| SC-01 | INVALID_OPERATION | `operation` is absent, empty, or not one of the 8 valid values | all |
| SC-02 | MISSING_UNIVERSAL_INPUT | Any of I-01 to I-06 is absent or empty | all |
| SC-03 | SESSION_ID_ABSENT | `session_id` not provided for `create-session` | create-session |
| SC-04 | TARGET_NOT_FOUND | `target_path` does not exist on disk | update-session, close-session |
| SC-05 | TARGET_ALREADY_CLOSED | Target document has `status: complete` OR `status: done` in frontmatter | update-session, close-session |
| SC-06 | TARGET_IS_LEGACY | Target document is dated 2026-03-12 or earlier | all |
| SC-07 | OUTPUT_ALREADY_EXISTS | `output_path` already exists on disk | create-session, create-daily-report |
| SC-08 | SOURCE_RANGE_VIOLATION | One or more source docs are outside active range (before 2026-03-13) | create-daily-report |
| SC-09 | OUTPUT_PATH_OUT_OF_BOUNDS | `output_path` is not inside the required subdirectory (`ai-sessions/YYYY-MM/` or `daily-reports/YYYY-MM/`) | create-session, create-daily-report |
| SC-10 | PROJECT_PATH_INVALID | `project_path` does not point to a valid project root (missing `PROJECT_CONTEXT.md`) | update-project-status, register-decision, update-next-step |
| SC-11 | PROJECT_ALREADY_EXISTS | Target folder already exists on disk | create-project |
| SC-12 | MISSING_PROJECT_INPUT | A required project-specific input (as listed in operation inputs) is absent or empty | all project operations |

---

## 13. Failure Modes

Failure modes fire **DURING execution**. Each has a trigger condition, severity, and required fallback action.

| ID | Name | Trigger | Severity | Fallback Action |
|---|---|---|---|---|
| FM-01 | SESSION_ID_ABSENT | Agent attempts to fabricate a session ID | Critical | Stop immediately. Escalate to Jimmy. Do not proceed. |
| FM-02 | DISCRIMINATOR_MISMATCH | Canonical discriminator in frontmatter does not match body | High | Recompute and fix before writing. If unable, escalate. |
| FM-03 | TIMESTAMP_DRIFT | `last_updated_at_local` in frontmatter does not match body | High | Synchronize both to current `timestamp_local`. |
| FM-04 | HISTORY_ORDER_VIOLATION | New history row was appended at bottom instead of prepended at top | Medium | Reorder: move new row to top of table. |
| FM-05 | SECTION_MISMATCH | Content added to wrong section based on `update_type` | High | Remove from wrong section, add to correct section. |
| FM-06 | TARGET_IS_LEGACY | Agent attempts to modify a document dated 2026-03-12 or earlier | Critical | Stop immediately. Escalate to Jimmy. Legacy docs are frozen. |
| FM-07 | DUPLICATE_SESSION_DOC | Output path already exists when creating new session | High | Fire SC-07. Do not overwrite. |
| FM-08 | WRITE_SURFACE_VIOLATION | Agent attempts to write outside allowed write surfaces | Critical | Stop immediately. Escalate to Jimmy and audit lead. Do not write. |
| FM-09 | CLEAN_STATE_BLOCKED | One or more clean-state criteria failed during close-session | High | Return failing criteria with evidence. Do not modify document. |
| FM-10 | PLACEHOLDER_DETECTED | Output document contains `{{...}}`, `TODO`, `TBD`, or `pending` as a value (not as an explicit status) | High | Do not deliver artifact. Fix all placeholders before writing. |
| FM-11 | STALE_PATH_DETECTED | Output document contains a path without the `skills/` segment where required | High | Do not deliver artifact. Fix all stale paths before writing. |
| FM-12 | TEMPLATE_READ_FAILURE | Template cannot be read from expected location | High | Fall back to embedded template in this skill. If embedded template also fails, escalate. |
| FM-13 | SOURCE_DOC_UNREADABLE | A source session doc in `source_session_docs` cannot be read | Medium | Skip unreadable doc, note in evidence block, proceed with remaining docs. |
| FM-14 | PROJECT_STRUCTURE_INCOMPLETE | `create-project` could not create all required folders or files. At least one subfolder or operational doc is missing after execution. | High | Return list of what failed, do not leave partial structure without reporting. |
| FM-15 | PROJECT_DOC_NOT_FOUND | The target operational document (`status-atual.md`, `decisoes.md`, or `next-step.md`) does not exist at `project_path`. | High | Escalate to Jimmy. Do not attempt to recreate it. |
| FM-16 | PROJECT_STATUS_SECTION_INVALID | The `section` value for `update-project-status` is not one of: `completed`, `in_progress`, `blocked`. | High | Return received value and valid options (`completed`, `in_progress`, `blocked`). |

---

## 14. Prohibited Behaviors

| ID | Rule | Description |
|---|---|---|
| PB-01 | NO_ID_FABRICATION | Never generate, invent, or guess session IDs. Session IDs MUST be provided externally. |
| PB-02 | NO_PARTIAL_CLOSE | Never mark a session as `complete` without full clean-state gate passing all 7 criteria. |
| PB-03 | NO_NW_WRITE | Never write to any path listed as non-writable (NW-01 to NW-10) from session/report operations. Note: project governance operations have their own write authorizations (WS-04 to WS-07). |
| PB-04 | NO_DIRTY_ARTIFACT | Never deliver a document containing `TODO`, `TBD`, `FIXME`, `{{...}}` placeholders, or unresolved `pending` values (except where `pending` is the legitimate initial state). |
| PB-05 | NO_VCS_OPERATION | Never execute git commands (commit, push, pull, branch, merge, rebase, etc.). |
| PB-06 | NO_SILENT_ABORT | Every abort must log the skip condition or failure mode ID and a human-readable reason. Never abort without explanation. |
| PB-07 | NO_LEGACY_MODIFICATION | Never modify documents dated 2026-03-12 or earlier. They are frozen. |
| PB-08 | NO_TEMPLATE_MODIFICATION | Never modify template files (RS-01, RS-03). |
| PB-09 | NO_OVERWRITE | Never overwrite an existing file during `create-session` or `create-daily-report`. |
| PB-10 | NO_CROSS_SESSION_MERGE | Never merge content from one session doc into another session doc. |
| PB-11 | NO_SCOPE_CREEP | Never make project decisions, code changes, or architectural choices. This skill is documentation-only. |
| PB-12 | NO_TIMESTAMP_FABRICATION | Never fabricate or estimate timestamps. Always use the real machine clock value from `timestamp_local`. |
| PB-13 | NO_PROJECT_DECISION_FABRICATION | Never fabricate or assume a decision. Decisions must come from Jimmy or be explicitly authorized by Jimmy. The only exception is the initial "project formally opened" decision created by `create-project`, which is a mechanical record of the creation event. |
| PB-14 | NO_PROJECT_OVERWRITE | Never overwrite existing project docs during `create-project`. If any of the 5 operational docs already exist at the target path, the operation must abort with SC-11. |
| PB-15 | NO_CROSS_PROJECT_WRITE | A project operation must only write within its own project folder. `update-project-status` on project A must never modify files under project B. |

---

## 15. Documentation Hygiene Rules

| ID | Rule | Description |
|---|---|---|
| DH-01 | EVIDENCE_REQUIRED | An evidence block must be produced after every operation (create, update, close, daily-report, and all project operations). |
| DH-02 | TIMESTAMP_COHERENCE | `last_updated_at_local` in frontmatter MUST equal `Last local update` in body header. Both update together, always. |
| DH-03 | HISTORY_PREPEND | New rows in the Modification History table are always prepended at the TOP. Newest first. |
| DH-04 | CANONICAL_DISCRIMINATOR | The canonical discriminator (`[session_id_short]-[machine_id]-[agent_slug]-[YYYY-MM-DD]`) must appear in frontmatter (`session_key`) AND in body (`Canonical operational discriminator`). |
| DH-05 | NO_STALE_PATHS | All paths in documents must include the `skills/` segment where applicable. Old-format paths without `skills/` are stale and must be corrected. |
| DH-06 | NO_PLACEHOLDERS | No `{{...}}` template markers, `TODO`, `TBD`, or `FIXME` in delivered documents. |
| DH-07 | ALIAS_IN_FILENAME | New files use the `ddi-email` alias in the filename where applicable (planning docs, specs, audits — not session docs or daily reports). |
| DH-08 | COMMIT_HASH_RECORDED | When commits happen (outside this skill), the commit hash must be recorded in the session doc's history table. |
| DH-09 | TEMP_ARTIFACTS_ACCOUNTED | All temporary artifacts (scratch files, debug logs, test outputs) must be accounted for: committed, discarded, or deferred with justification. |
| DH-10 | CLEAN_STATE_ITEMIZED | Clean-state evidence must be itemized per criterion (CS-01 through CS-07). Blanket "all good" statements are not acceptable. |
| DH-11 | DECISION_FORMAT | Every decision entry in `decisoes.md` must have all three fields: `Decision:`, `Reason:`, `Impact:`. No partial entries. An entry missing any field is a hygiene violation. |
| DH-12 | STATUS_DATE | `Last Update` in `status-atual.md` must always reflect the date of the most recent change. After any write to `status-atual.md`, the `Last Update` field must be set to the current date. |
| DH-13 | PROJECT_WIKILINKS | All 5 operational docs (`PROJECT_CONTEXT.md`, `status-atual.md`, `next-step.md`, `decisoes.md`, `README.md`) must have wikilinks connecting them to each other and to `[[projects]]`. A doc without its wikilinks section is non-compliant. |
| DH-14 | WIKILINK_NO_ORPHANS | Every document under the `obsidian/` directory tree must have a `## Wikilinks` section at the bottom. No document may be orphaned (disconnected from the graph). Additionally: (a) any document related to a project must include `[[projects]]` in its wikilinks; (b) any document related to or associated with a skill must also include `[[skills]]` in its wikilinks. These two wikilinks (`[[projects]]` and `[[skills]]`) are mandatory connectors when applicable. |
| DH-15 | PROJECT_SYNC_BEFORE_CLOSE | Before closing a session doc or creating a daily report, the agent MUST update the operational docs (status-atual.md, next-step.md, decisoes.md) of every project referenced in the session. This includes: (a) moving completed items from In Progress to Completed in status-atual.md; (b) updating next-step.md with the current immediate action; (c) registering any decisions made during the session in decisoes.md. Session closure without project sync is a hygiene violation. |
| DH-16 | FINDINGS_TRACKING | When a finding is discovered during any session: (a) add `## Findings` section right after `## Current Snapshot`; (b) set `has_findings: true` in frontmatter; (c) register in master index at `C:\ai\obsidian\CIH\projects\_findings\findings-master-index.md` with sequential `FND-XXXX` ID; (d) set status in session doc to `indexed` once registered in master (`pending` is transient — only until registration completes, must not persist past session close); (e) agents seeing `indexed` MUST NOT attempt to resolve or re-register — current status lives in master index only; (f) when changing a finding's status in the master index, simultaneously update the corresponding `FND-XXXX.md` detail file — both must always be in sync, updating only one is a hygiene violation; (g) **COUNTER SYNC (FND-0018):** the master index has TWO counter locations — frontmatter fields AND the `## Summary` table in the body. When ANY finding is added, resolved, or changes status, BOTH locations MUST be updated atomically in the same edit. A mismatch between frontmatter and Summary is a hygiene violation. For project closure: sweep all session docs and reconcile with master index (CS-08). |
| DH-17 | ORPHAN_DETECTION | Before session close or daily report creation, the agent MUST verify that no new orphaned documents were introduced during the session. An orphan is a `.md` file under `obsidian/` that either: (a) lacks a `## Wikilinks` section, or (b) has zero incoming `[[wikilinks]]` from any other file. Detection can be performed by running `_skills/daily-doc-information/orphan-detector.sh` or by manual inspection. New orphans introduced during the session block closure (PP-09). Pre-existing orphans should be reported but do not block closure. |

---

## 16. Read/Write Surface Boundaries

### Allowed Read Surfaces

| ID | Surface | Description |
|---|---|---|
| RS-01 | `ai-sessions/ai-session-template.md` | Session document template |
| RS-02 | `ai-sessions/YYYY-MM/*.md` | Session docs dated 2026-03-13 or later |
| RS-03 | `daily-reports/daily-report-template.md` | Daily report template |
| RS-04 | `daily-reports/YYYY-MM/*.md` | Daily reports dated 2026-03-13 or later |
| RS-05 | `PROJECT_CONTEXT.md` | Project context reference (read-only) |
| RS-06 | `projects/_templates/*.md` | Templates for project creation |
| RS-07 | `projects/skills/{project}/PROJECT_CONTEXT.md` | Project identification for skill projects |
| RS-08 | `projects/{project}/PROJECT_CONTEXT.md` | Project identification for general projects |
| RS-09 | `projects/skills/{project}/status-atual.md` | Read before update to preserve existing content |
| RS-10 | `projects/skills/{project}/decisoes.md` | Read before register to preserve existing entries |
| RS-11 | `projects/skills/{project}/next-step.md` | Read before update to preserve existing content |
| RS-12 | `projects/{project}/status-atual.md` | Same as RS-09, for general projects |
| RS-13 | `projects/{project}/decisoes.md` | Same as RS-10, for general projects |
| RS-14 | `projects/{project}/next-step.md` | Same as RS-11, for general projects |

### Allowed Write Surfaces

| ID | Surface | Operation | Description |
|---|---|---|---|
| WS-01 | `ai-sessions/YYYY-MM/<new-session>.md` | create-session | New session documents only |
| WS-02 | `ai-sessions/YYYY-MM/<existing-session>.md` | update-session, close-session | Existing open session documents only |
| WS-03 | `daily-reports/YYYY-MM/<new-report>.md` | create-daily-report | New daily reports only |
| WS-04 | `projects/skills/{project}/*.md` | create-project, update-project-status, register-decision, update-next-step | Skill project operational docs |
| WS-05 | `projects/skills/{project}/*/` | create-project | Skill project subfolders (creation only) |
| WS-06 | `projects/{project}/*.md` | create-project, update-project-status, register-decision, update-next-step | General project operational docs |
| WS-07 | `projects/{project}/*/` | create-project | General project subfolders (creation only) |

### Non-Writable Surfaces

| ID | Surface | Reason |
|---|---|---|
| NW-01 | `PROJECT_CONTEXT.md` | Project governance document — read-only for all operations. Only `create-project` may create it; no operation may modify it after creation. |
| NW-02 | `status-atual.md` | Forbidden for session/report ops. Authorized for `update-project-status` via WS-04/WS-06. |
| NW-03 | `next-step.md` | Forbidden for session/report ops. Authorized for `update-next-step` via WS-04/WS-06. |
| NW-04 | `decisoes.md` | Forbidden for session/report ops. Authorized for `register-decision` via WS-04/WS-06. |
| NW-05 | `02-planning/` | Planning directory — manual edits only |
| NW-06 | `03-spec/` | Specification directory — manual edits only |
| NW-07 | `05-audits/` | Audit directory — manual edits only |
| NW-08 | `04-prompts/` | Prompts directory — manual edits only |
| NW-09 | `ai-sessions/ai-session-template.md` | Template — never modify |
| NW-10 | `daily-reports/daily-report-template.md` | Template — never modify |

---

## 17. Embedded Templates

### 15.1 Session Document Template

```markdown
---
title: "Session Log - {{AGENT_NAME}} - {{YYYY-MM-DD}}"
date: {{YYYY-MM-DD}}
session_id: {{SESSION_ID}}
session_id_short: {{SESSION_ID_SHORT}}
session_key: {{SESSION_ID_SHORT}}-{{MACHINE_NAME}}-{{AGENT_SLUG}}-{{YYYY-MM-DD}}
session_name: {{SESSION_NAME}}
agent_name: {{AGENT_NAME}}
agent_slug: {{AGENT_SLUG}}
agent: {{AGENT_LABEL}}
provider: {{PROVIDER}}
llm_model: {{LLM_MODEL}}
timezone: America/Sao_Paulo
location: Brasilia, Brasil
time_reference: machine local time
opened_at_local: {{YYYY-MM-DD HH:MM}}
last_updated_at_local: {{YYYY-MM-DD HH:MM}}
closed_at_local: pending
checkpoint: 01
machine: {{MACHINE_NAME}}
user: {{OS_USER}}
cat_doc: Session Log
context_type: {{CONTEXT_TYPE}}
project: {{PROJECT}}
main_subject: {{MAIN_SUBJECT}}
secondary_subjects:
  - {{SUBJECT_1}}
time_of_day: {{TIME_OF_DAY}}
day_type: {{DAY_TYPE}}
tags:
  - ai-session
  - session-log
  - {{AGENT_SLUG}}
  - {{PROJECT_TAG}}
status: in_progress
has_findings: false
aliases:
  - session-{{SESSION_ID_SHORT}}-{{YYYY-MM-DD}}-{{AGENT_SLUG}}
---

# Session Log - {{AGENT_NAME}} - {{YYYY-MM-DD}}

> **Date:** {{YYYY-MM-DD}}
> **Machine:** {{MACHINE_NAME}} (`{{OS_USER}}`)
> **Session ID:** `{{SESSION_ID}}`
> **Session ID short (filename):** `{{SESSION_ID_SHORT}}`
> **Canonical operational discriminator:** `{{SESSION_ID_SHORT}}-{{MACHINE_NAME}}-{{AGENT_SLUG}}-{{YYYY-MM-DD}}`
> **Session Name:** `{{SESSION_NAME}}`
> **Agent:** {{AGENT_LABEL}}
> **Provider:** {{PROVIDER}}
> **LLM Model:** {{LLM_MODEL}}
> **Context Type:** `{{CONTEXT_TYPE}}`
> **Project:** `{{PROJECT}}`
> **Macro period:** {{TIME_OF_DAY}}
> **Actual local open:** {{YYYY-MM-DD HH:MM}}
> **Last local update:** {{YYYY-MM-DD HH:MM}}
> **Actual local close:** pending
> **Timezone:** `America/Sao_Paulo`
> **Reference locality:** `Brasilia, Brasil`
> **Time reference:** `machine local time`
> **Previous session:** {{PREVIOUS_SESSION}}
> **Target file/prompt:** {{TARGET_FILE}}

---

## Current Snapshot

| Field | Value |
|---|---|
| Owner | {{AGENT_NAME}} |
| Overall status | in_progress |
| Main context | {{CONTEXT_TYPE}} |
| Main project | {{PROJECT}} |
| Active block | B01 |
| Next action | pending |
| Blockers | pending |
| Clean-state gate | pending |
| Daily curated by | pending |

---

<!-- FINDINGS SECTION: Add this section ONLY when findings are discovered during the session.
     When adding this section, set has_findings: true in the frontmatter.
     Place it here — right after Current Snapshot, before Modification History.

## Findings

| ID | Type | Severity | Description | Root Cause | Solution | Affected Skill | Status |
|---|---|---|---|---|---|---|---|
| FND-XXXX | CP/PL/INT | CRITICAL/HIGH/MEDIUM/LOW | Short description | Why it happened | How to fix | Skill or process affected | pending → indexed |

Rules:
- ID from findings-master-index.md (next sequential FND-XXXX)
- Type: CP (cross-project), PL (project-level), INT (internal/self)
- Status flow in session docs: `pending` (just discovered, not yet in master) → `indexed` (registered in master with FND-XXXX).
- `pending` is transient — must be resolved to `indexed` before session close.
- `indexed` is permanent — means "tracked in master index, no action needed here."
- An agent seeing `indexed` MUST NOT attempt to resolve or re-register the finding. Current status is in the master index only.
- Register in findings-master-index.md simultaneously upon discovery.
-->

## Modification History

| Date | Macro period | Local time | Timezone | Agent | Machine | Change |
|---|---|---|---|---|---|---|
| {{YYYY-MM-DD}} | {{TIME_OF_DAY}} | {{HH:MM}} | America/Sao_Paulo | {{AGENT_LABEL}} | {{MACHINE_NAME}} | Session doc created. |

> Rule: new rows go at the top of the table.

---

## Work Blocks

| Block | Context Type | Project | Status | Last Update | Next Action |
|---|---|---|---|---|---|
| B01 - {{BLOCK_TITLE}} | {{CONTEXT_TYPE}} | {{PROJECT}} | In Progress | {{HH:MM}} | pending |

---

## Handoff

### Where this session stopped
- pending

### Where to resume
- pending

### What not to reopen
- pending

### Files to read first
1. pending

---

## Wikilinks

[[ai-sessions]] | [[daily-report]] | [[{{AGENT_NAME}}]]
```

### 15.2 Daily Report Template

```markdown
---
title: "Daily Executive Report - {{YYYY-MM-DD}}"
date: {{YYYY-MM-DD}}
doc_id: daily-report-executive-{{YYYY-MM-DD}}-v1
cat_doc: Daily Executive Report
report_type: executive
report_period: daily
timezone: America/Sao_Paulo
location: Brasilia, Brasil
time_reference: machine local time
opened_at_local: {{YYYY-MM-DD HH:MM}}
updated_at_local: {{YYYY-MM-DD HH:MM}}
agents:
  - {{AGENT_LIST}}
sessions_covered:
  - {{SESSION_IDS}}
total_sessions: {{N}}
active_range_policy: active_2026-03-13_plus
tags:
  - daily-report
  - executive
status: in_progress
version: 1.0.0
author: {{AUTHOR}}
created_at: {{YYYY-MM-DD}}
updated_at: {{YYYY-MM-DD}}
aliases:
  - daily-exec-{{YYYY-MM-DD}}
---

# Daily Executive Report - {{YYYY-MM-DD}}

> **Period:** {{YYYY-MM-DD}}
> **Timezone:** `America/Sao_Paulo`
> **Reference locality:** `Brasilia, Brasil`
> **Time reference:** `machine local time`
> **Last local update:** {{YYYY-MM-DD HH:MM}}
> **Status:** in_progress

---

## Current Snapshot

| Field | Value |
|---|---|
| Project Work | {{SUMMARY}} |
| General Work | {{SUMMARY}} |
| Consolidation moment | end of day |
| Next consolidation | pending |
| Active window | `2026-03-13+` |
| Curation | {{AUTHOR}} |

---

<!-- FINDINGS SUMMARY: Include this section ONLY if any session doc from this day has has_findings: true.
     Place here — after Current Snapshot, before Project Work.

## Findings Summary

| ID | Source Session | Type | Severity | Description | Status |
|---|---|---|---|---|---|
| FND-XXXX | session-XXXX | CP | HIGH | Short description | pending |

Total: X findings | Y pending | Z resolved
-->

## Project Work

### {{PROJECT_NAME}}

- **Project Name:** {{PROJECT_NAME}}
- **Key Actions:** {{KEY_ACTIONS}}
- **Progress:** {{PROGRESS}}
- **Major Decisions:** {{DECISIONS}}
- **Blockers:** {{BLOCKERS}}

---

## General Work

### {{TASK_THEME}}

- **Task/Theme:** {{TASK_THEME}}
- **Key Actions:** {{KEY_ACTIONS}}
- **Outcome / Current Status:** {{STATUS}}
- **Next Step:** {{NEXT}}

---

## Linked Official Sessions

| # | Session ID | Agent | Project | Status |
|---|---|---|---|---|
| 1 | {{SESSION_ID}} | {{AGENT}} | {{PROJECT}} | {{STATUS}} |

---

## Usage Rules

- this document is consolidated once per day, at closure;
- use the day's session docs as the operational source of truth;
- do not treat this file as an iteration log for each agent;
- documents from 2026-03-12 and earlier are frozen.

---

## Wikilinks

[[daily-report]] | [[ai-sessions]]
```

### 15.3 Project Document Templates

#### 15.3.1 PROJECT_CONTEXT.md

```markdown
# Project Context

Project Name:
{{PROJECT_NAME}}

Objective:
{{PROJECT_OBJECTIVE}}

Current Phase:
{{CURRENT_PHASE}}

Current Status:
See status-atual.md

Next Action:
See next-step.md

Core Documents:
- {{CORE_DOC_1}}
- {{CORE_DOC_2}}

Decision Log:
See decisoes.md

Standard Project Status Summary:

When Jimmy asks for the current status of a project, answer in this fixed shape:

- Current phase
- Overall progress
- Already completed
- Where we stopped
- Blockers
- Official next step
- Guardrails / out of scope now

Keep the answer short, literal, and derived from `PROJECT_CONTEXT.md`, `status-atual.md`, `next-step.md`, and `decisoes.md`.

Operational Protocol:

Before executing any task:

1. Read PROJECT_CONTEXT.md
2. Read status-atual.md
3. Read next-step.md
4. Read decisoes.md

---

## Wikilinks

[[projects]] | [[{{PROJECT_NAME}}]]
```

**Variable substitution rules for PROJECT_CONTEXT.md:**

| Variable | Source |
|---|---|
| `{{PROJECT_NAME}}` | I-50 `project_name` |
| `{{PROJECT_OBJECTIVE}}` | I-52 `objective` |
| `{{CURRENT_PHASE}}` | I-53 `initial_phase` |
| `{{CORE_DOC_1}}` | `PROJECT_CONTEXT.md` (self-reference) |
| `{{CORE_DOC_2}}` | `status-atual.md` |

#### 15.3.2 status-atual.md

```markdown
# Current Status

Current Phase:
{{CURRENT_PHASE}}

Completed
- (none yet)

In Progress
- {{IN_PROGRESS_ITEM_1}}

Blocked
- (none)

Overall Progress
{{INITIAL_PROGRESS}}

Last Update
{{YYYY-MM-DD}}

---

## Wikilinks

[[projects]] | [[{{PROJECT_NAME}}]] | [[PROJECT_CONTEXT]] | [[next-step]] | [[decisoes]]
```

**Variable substitution rules for status-atual.md:**

| Variable | Source |
|---|---|
| `{{CURRENT_PHASE}}` | I-53 `initial_phase` |
| `{{IN_PROGRESS_ITEM_1}}` | Derived: `"Project kickoff and initial structure"` (default initial item) |
| `{{INITIAL_PROGRESS}}` | Derived: `"Project formally opened. Initial structure created."` |
| `{{YYYY-MM-DD}}` | Date portion of I-54 `timestamp_local` |
| `{{PROJECT_NAME}}` | I-50 `project_name` |

#### 15.3.3 next-step.md

```markdown
# Next Step

Immediate Action

{{IMMEDIATE_ACTION}}

Required Reading
- PROJECT_CONTEXT.md
- status-atual.md

Completion Criteria

{{COMPLETION_CRITERIA}}

---

## Wikilinks

[[projects]] | [[{{PROJECT_NAME}}]] | [[PROJECT_CONTEXT]] | [[status-atual]] | [[decisoes]]
```

**Variable substitution rules for next-step.md:**

| Variable | Source |
|---|---|
| `{{IMMEDIATE_ACTION}}` | Derived: `"Read PROJECT_CONTEXT.md and confirm project scope with Jimmy."` (default initial action) |
| `{{COMPLETION_CRITERIA}}` | Derived: `"Jimmy has confirmed the project scope and objective."` |
| `{{PROJECT_NAME}}` | I-50 `project_name` |

#### 15.3.4 decisoes.md

```markdown
# Decision Log

## {{YYYY-MM-DD}}

Decision:
Project {{PROJECT_NAME}} formally opened.

Reason:
{{PROJECT_OBJECTIVE}}

Impact:
Project folder structure created. Operational documents initialized.

---

## Wikilinks

[[projects]] | [[{{PROJECT_NAME}}]] | [[PROJECT_CONTEXT]] | [[status-atual]] | [[next-step]]
```

**Variable substitution rules for decisoes.md:**

| Variable | Source |
|---|---|
| `{{YYYY-MM-DD}}` | Date portion of I-54 `timestamp_local` |
| `{{PROJECT_NAME}}` | I-50 `project_name` |
| `{{PROJECT_OBJECTIVE}}` | I-52 `objective` |

#### 15.3.5 README.md

```markdown
# {{PROJECT_NAME}}

{{PROJECT_OBJECTIVE}}

## Status

See [status-atual.md](status-atual.md) for current status.

## Documents

- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) — Project context and operational protocol
- [status-atual.md](status-atual.md) — Current status
- [next-step.md](next-step.md) — Next action
- [decisoes.md](decisoes.md) — Decision log

---

## Wikilinks

[[projects]] | [[{{PROJECT_NAME}}]] | [[PROJECT_CONTEXT]] | [[status-atual]] | [[next-step]] | [[decisoes]]
```

### 15.4 Project Notes and Threads Template

**Template name:** Project Notes and Threads

**Filename pattern:** `ddi-pjt-gi-notes-ans-{owner}-{orchestrator}.md` (one file per project, in `00-prompts/` or `00_prompts_agents/` folder)

```markdown
# Project Notes, Threads and Discussions

> **Project:** {{PROJECT_NAME}}
> **Created:** {{YYYY-MM-DD}}
> **Purpose:** Parallel discussions, clarifications, notes, and Q&A threads that do not belong in session docs, daily reports, or planning documents. One file per project. Permanent record.

## How to use this file

1. **Opening a thread:** Add a new section with header `### YYYY-MM-DD-who-##` (e.g., `### 2026-03-17-jimmy-01`)
2. **Entries:** Each thread has entries from participants: `#### {Name}'s Entry` followed by content
3. **Read receipts:** When you read an entry, add a tick: `#### {Name}'s Entry ✅ read-YYYY-MM-DD-HH:MM-{reader}`
4. **Thread numbering:** Sequential per day per person (01, 02, 03...)
5. **Linking:** Session docs and daily reports can reference threads via `[[filename#YYYY-MM-DD-who-##]]`
6. **Never delete:** Threads are permanent record. Mark resolved threads with `[RESOLVED]` in the header if needed.

---

### YYYY-MM-DD-who-##

#### {Name}'s Entry
{Content here}

#### {Responder}'s Entry
{Response here}

---

## Wikilinks

[[projects]] | [[{{PROJECT_NAME}}]]
```

**Variable substitution rules for the notes file:**

| Variable | Source |
|---|---|
| `{{PROJECT_NAME}}` | I-50 `project_name` |
| `{{YYYY-MM-DD}}` | Date portion of I-54 `timestamp_local` |

---

## 18. Standard Status Summary

When any agent is asked for the current status of a project, it MUST answer in this fixed shape. The data sources for each field are specified.

```
- Current phase: [from PROJECT_CONTEXT.md Current Phase]
- Overall progress: [from status-atual.md Overall Progress]
- Already completed: [from status-atual.md Completed section]
- Where we stopped: [from status-atual.md In Progress + last update]
- Blockers: [from status-atual.md Blocked section]
- Official next step: [from next-step.md Immediate Action]
- Guardrails / out of scope now: [from PROJECT_CONTEXT.md or decisoes.md]
```

This format is embedded in every `PROJECT_CONTEXT.md` created by `create-project` and must not be modified or abbreviated by any agent. If any of the source fields is empty or not yet populated, the agent must report `(not yet defined)` rather than fabricating content.

---

## 19. Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.6.0 | 2026-03-24 | Magneto (Orchestrator) | Strategic Project Portfolio: new `update-portfolio` operation (Op 10), portfolio document at `obsidian/CIH/projects/strategic-project-portfolio.md`. PP-09 retired (orphan detection removed from checkpoint gate). PP-10 added (stale session detection, FND-0031). `checkpoint-verify.sh` updated with PP-10 automation. Sections renumbered (11→12 through 17→19). |
| 1.5.0 | 2026-03-23 | Magneto (Orchestrator) | LLM model tracking (FND-0024): `llm_model` field in session template and universal inputs (I-07). Checkpoint automation: Claude Code hook + verification script + keyword gates. |
| 1.4.0 | 2026-03-22 | Magneto (Orchestrator) | Orphan detection: DH-17 (ORPHAN_DETECTION) hygiene rule. PP-09 check in Pre-Close gate. `orphan-detector.sh` script for automated scanning of missing `## Wikilinks` sections and true orphans (zero incoming links). Runs in ~1.5s for 370+ files. |
| 1.3.0 | 2026-03-20 | Magneto (Orchestrator) | Findings tracking system: CS-08 (findings reconciled) as mandatory clean-state criterion for project closure. DH-16 (FINDINGS_TRACKING) hygiene rule. `has_findings` frontmatter field in session template. Conditional Findings section after Current Snapshot. Findings Summary in daily report template. Master index at `_findings/findings-master-index.md`. |
| 1.2.0 | 2026-03-19 | Magneto (Orchestrator) | Added CS-07 (project docs synchronized) as mandatory clean-state criterion — blocks session closure if referenced project docs are stale. Added DH-15 (PROJECT_SYNC_BEFORE_CLOSE) hygiene rule. Prevents drift between session docs and project operational docs. |
| 1.1.1 | 2026-03-19 | Magneto (Orchestrator) | Added DH-14 (WIKILINK_NO_ORPHANS): no orphaned docs under obsidian/, mandatory [[projects]] and [[skills]] wikilinks when applicable. |
| 1.1.0 | 2026-03-19 | Magneto (Orchestrator) | Full English translation of all embedded templates and body references. Portuguese section headers, field labels, and status summary format replaced with American English equivalents. Backward compatible — existing docs retain original language. |
| 1.0.0 | 2026-03-18 | Magneto (Orchestrator) | First official publication. G-03 approved by Jimmy. 8 operations, cross-agent, cross-machine, full test suite. |
| 0.3.1-prototype | 2026-03-18 | Magneto (Orchestrator) | Fix 3 audit findings: F-01 (accept done+complete as closed), F-02 (backward-compat folder names), F-03 (SC-05 accepts done+complete) |
| 0.3.0-prototype | 2026-03-17 | Magneto (Orchestrator) | Cross-agent compatibility section, environment configuration for cross-machine portability, project notes/threads template added to embedded templates and create-project operation |
| 0.2.0-prototype | 2026-03-17 | Magneto (Claude Code - Opus 4.6) | Project governance expansion — added 4 new operations (create-project, update-project-status, register-decision, update-next-step), extended skip conditions (SC-10 to SC-12), failure modes (FM-14 to FM-16), prohibited behaviors (PB-13 to PB-15), hygiene rules (DH-11 to DH-13), read/write surfaces (RS-06 to RS-14, WS-04 to WS-07), embedded project templates, and Standard Status Summary format. Based on Round 05 spec. |
| 0.1.0-prototype | 2026-03-17 | Magneto (Claude Code - Opus 4.6) | Initial prototype — all 4 operations, skip conditions, failure modes, hygiene rules, embedded templates |
