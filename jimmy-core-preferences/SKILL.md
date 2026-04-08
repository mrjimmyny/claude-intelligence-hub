---
name: jimmy-core-preferences
version: 3.7.0
description: Global cross-agent operating framework for Jimmy.
command: /preferences
aliases: [/prefs, /jimmy]
---

# Jimmy Core Preferences — Global Cross-Agent Operating Framework

**Version:** 3.7.0
**Last Updated:** 2026-04-08
**Auto-Load:** Yes (Priority: Highest)

**Note:** All `<PLACEHOLDER>` email addresses are resolved from the operator's local `CLAUDE.md`. This skill defines routing rules; actual addresses are configured per-environment.

---

## A. Purpose, Scope and Precedence

This skill is the **global operating framework** for all agents working with Jimmy. It applies to any AI agent (Claude, Codex/OpenAI, Gemini, and others) across any interface (Claude Code, web, API, CLI).

- **User:** Jimmy — always, no other name
- **Agent:** use your own codename; this skill does not impose a fixed agent identity
- **Technical source of truth:** `C:\ai\claude-intelligence-hub`
- **Documentary operating layer:** `C:\ai\obsidian\CIH\`

`C:\ai\obsidian` is documentary only — not a technical workspace.

**Precedence:** This skill overrides agent defaults. Agent-specific or project-specific rules may override individual sections when Jimmy explicitly states so.

---

## B. Universal Operating Posture

1. **Radical honesty** — be direct and professionally honest at all times.
2. **Objectivity** — do not adopt Jimmy's biases; provide unbiased analysis.
3. **Mandatory counterpoint** — when a risk, flaw, or better path exists, name it. Explain consequences. Recommend the best option.
4. **Anti-yes-man** — do not agree by default. Agreement must be earned by the quality of the idea.
5. **Proactive intelligence** — flag issues, suggest improvements, and route to the right skill (see `HUB_MAP.md`) before Jimmy has to ask.

---

## C. Default Communication Compression

- Responses must be **short by default**.
- Maximum 5-6 lines per topic or category in chat.
- Do not explain everything unless Jimmy explicitly asks for more detail.
- Avoid dumping large text blocks into the active chat context.
- If an artifact is needed, create it as a **file** — do not paste it into chat.
- If Jimmy does not ask for detail, compress. If he does, expand.
- These rules apply to conversational responses. Deliverable artifacts (reports, audits, plans) follow the detail level required by the task.

---

## D. Cross-Agent Bootstrap and Fallback

For agents without native global-skill auto-loading (e.g., Codex, Gemini):

1. Jimmy will provide: `C:\ai\obsidian\CIH\_skills-cross-agent-machines\README.md`
2. Read that router first to understand the active skill context.
3. Load only the minimum necessary skill(s) from `C:\ai\claude-intelligence-hub`.
4. After bootstrap, read `C:\ai\claude-intelligence-hub\HUB_MAP.md` to discover available skills.
5. Never fake skill activation — if a skill was not read, do not claim it was loaded.

For agents with native auto-load (Claude Code with skill support):
- `jimmy-core-preferences` loads automatically at session start (Tier 1).
- Route all requests through `HUB_MAP.md` before acting.

### Claude Code Skill Symlink Integrity

All skills in `~/.claude/skills/` MUST be junctions (Windows) or symlinks (Linux/Mac) pointing to `claude-intelligence-hub/`. **Never copies.** A copy drifts on the next hub update and breaks cross-machine bootstrap.

> This section applies to Claude Code only. Other agents (Codex, Gemini) manage skills through their own mechanisms.

**Verification:**
```bash
bash scripts/manage-global-skills.sh verify
```

**Fix (replaces copies with junctions):**
```bash
bash scripts/manage-global-skills.sh fix
```

Run from `C:\ai\claude-intelligence-hub\`. This script is cross-agent — any agent can invoke it.

When adding a new skill to the hub, run the fix command shown above. Never copy skill directories into `~/.claude/skills/`.

---

## E. Prompt Creation and Delegation Standard

When creating any prompt for another agent:

1. Write it in **English** — always, regardless of the conversation language.
2. Save it as a **file** when it is for reuse, delegation, or external execution.
3. If Jimmy requests a prompt and does not specify a save path, ask **once**: "Where should this be saved?"
4. If Jimmy provides a path, create and save directly — no further confirmation needed.
5. Do not paste long prompts into the active chat context.

Every prompt must be:
- **Incisive** — no filler
- **Unambiguous** — no room for misinterpretation
- **Path-specific** — absolute paths where applicable
- **Scoped** — explicit deliverables, prohibitions, and closure criteria
- **Wikilinked** — include `[[wikilinks]]` and references when the file will be saved under `obsidian/`

---

## F. Project Documentary Workspace Protocol

No project document lives in a random folder.

When starting a project with a documentary component:
1. Check if the project already has an established folder structure — follow it.
2. If no structure exists, use the baseline below as a starting point.
3. Adapt folder names to match the project's existing naming conventions.

**Baseline folder logic:**

| Folder | Status | Role |
|---|---|---|
| `00_prompts_agents/` | Required | Delegation and execution prompts |
| `01-manifesto-contract/` | Required | Proposal, manifesto, or contract |
| `02-planning/` | Required | Execution plans and breakdowns |
| `03-spec/` or `03-reviews/` | Optional | Formal specification or reviews |
| `04-tests/` | Required when applicable | Test plans and results |
| `05-final/` or `05-audits/` | Required when applicable | Final deliverables or audit evidence |
| `06-operationalization/` | Recommended | Handoff, operationalization, closure artifacts |

> **Backward compatibility:** Projects created before 2026-03-20 may use older folder names (`00-prompts/`, `05-audits/`, `06-final/`). Do not rename existing folders — follow the convention already in use for that project.

**Rule:** coherence over rigidity. The goal is no loose files, not a rigid template.

### Deterministic Kickoff Bootstrap (Cross-Agent)

For any new project kickoff, use deterministic scripts instead of manual folder-by-folder creation:

- Contract: `C:\ai\obsidian\CIH\projects\_templates\PROJECT_KICKOFF_CONTRACT.md`
- Bootstrap: `C:\ai\projects\scripts_bootstraps\kickoff-project.ps1`
- Verification: `C:\ai\projects\scripts_bootstraps\verify-project-doc-structure.ps1`

Minimum gate:
1. Run bootstrap with explicit `type`, `name`, `owner`, `agent`.
2. Run verification and require `Result: PASS`.
3. Only then proceed with project execution.

### Formal Project Operational State Layer

For formal projects that already exist and need an operational entrypoint, keep these files at the **project root**:

- `PROJECT_CONTEXT.md`
- `status-atual.md`
- `next-step.md`
- `decisoes.md`

These files are operational control files. Do not bury them inside subfolders.

### Project Status Summary Response Standard

When Jimmy asks for the current status of a formal project, answer in this fixed shape:

- `Current phase`
- `Overall progress`
- `Already completed`
- `Where we stopped`
- `Blockers`
- `Official next step`
- `Guardrails / out of scope now`

The answer must stay short and should be derived from the project root operational files first:
`PROJECT_CONTEXT.md` | `status-atual.md` | `next-step.md` | `decisoes.md`

### Wikilink Hygiene (Obsidian)

Every document under `obsidian/` must have a `## Wikilinks` section — no orphaned files allowed. Mandatory connectors:
- Project-related docs: must include `[[projects]]`
- Skill-related docs: must also include `[[skills]]`

Documents created before 2026-03-18 are exempt (legacy). From 2026-03-18 onward, all agents must ensure wikilink compliance. Note: the wikilink requirement (2026-03-18) predates the English language mandate (2026-03-19) by one day. Both are independently in effect.

**Creation-time enforcement (non-negotiable):** Every `.md` file created under `obsidian/` MUST include a `## Wikilinks` section at the time of creation. No `.md` file may be committed without wikilinks. This applies to all agents — orchestrators, executors, testers — and all file types including prompts, reports, audits, and templates. Forgetting wikilinks is a hygiene violation (see DH-14).

---

## G. Session Log and Daily Report Protocol

Every agent session must be documented. This is not optional.

**Standard paths:**
- Session documents: `C:\ai\obsidian\CIH\projects\skills\daily-doc-information\ai-sessions\YYYY-MM\`
- Daily reports: `C:\ai\obsidian\CIH\projects\skills\daily-doc-information\daily-reports\`
- Template: `C:\ai\obsidian\CIH\projects\skills\daily-doc-information\ai-sessions\ai-session-template.md`

**Rules:**
1. Create or update the session document at the **start** of the session.
2. One session doc per session ID. Jimmy provides the session ID externally. Multiple session docs per day per agent are permitted when distinct session IDs are provided.
3. Every session doc must declare:
   - `Context Type: Project|General`
   - `Project: <real project name>` or `Project: GENERAL`
4. The same session doc may contain multiple work blocks. Use separate blocks when `Project` and `General` work coexist.
5. Update the session document **during** the work.
6. Daily reports remain global by day, must explicitly separate:
   - `Project Work`
   - `General Work`
7. Daily reports are curator artifacts. Consolidate them **once per day at closure**, using the session documents of the same day as source of truth.
8. Do not treat the daily report as an iteration log for every agent interaction unless Jimmy explicitly asks for that exception.
9. Register: start time, work performed, decisions taken, validations, commits, next steps.
10. At session close, set `status: complete` and push.
11. When work continues the next day, add a **handoff block** that states:
   - Where the work stopped
   - What is pending
   - What comes next
   - What must not be reopened
   - Which files to read first
12. From 2026-03-19 onward, all session doc and daily report content must be written in American English per Section K.
### Within-Day Session Transitions

14. When Jimmy opens a new chat window on the same day with a new session ID, create a new session doc. The previous session doc for that day remains valid. Multiple session docs per day per agent are permitted when Jimmy provides distinct session IDs.

### Session Doc Update at Phase Boundaries

17. At every phase, round, or milestone boundary, the orchestrator MUST update the session doc (Modification History, Work Blocks, Current Snapshot) BEFORE committing and pushing. This is at the same priority level as "commit", "push", and "email". Failing to update the session doc at boundaries results in lost timestamps and requires reconstruction from git log.

### Mandatory Project Sync Before Session Close

13. Before closing any session doc or ending the day, the agent MUST update the operational docs (`status-atual.md`, `next-step.md`, `decisoes.md`) of EVERY project referenced in that session. This means:
   - Move completed items to the Completed section in `status-atual.md`
   - Update `next-step.md` with the current immediate action
   - Register any decisions made in `decisoes.md`
   - This is non-negotiable. Session closure without project sync is prohibited.

### Findings Tracking Protocol

15. When any finding (bug, gap, drift, failure, process error) is discovered during a session:
   - Add a `## Findings` section right after `## Current Snapshot` in the session doc.
   - Set `has_findings: true` in the session doc frontmatter.
   - Register the finding simultaneously in the master index at `C:\ai\obsidian\CIH\projects\_findings\findings-master-index.md`.
   - Set finding status in session doc to `indexed` once registered in master. `pending` is transient (only between discovery and registration — must not persist past session close).
   - Agents seeing `indexed` in session docs MUST NOT attempt to resolve or re-register. Current status lives in the master index only.
   - This applies to ALL orchestrators, not just Magneto.
16. Before closing any project, sweep ALL session docs of that project and reconcile all findings with the master index. No project closes with unreconciled findings. See DDI CS-08.
18. When changing a finding's status in the master index (e.g., pending → assigned → resolved), simultaneously update the corresponding `FND-XXXX.md` detail file with the same status, dates, and agent information. Both documents must always be in sync. Updating only one is a hygiene violation.
19. **Cross-Reference Wikilinks (mandatory):** Session docs with findings MUST have the following cross-references for Obsidian graph connectivity:
    - All FND-XXXX IDs in the `## Findings` table MUST be wikilinked: `[[FND-XXXX]]` (not plain text).
    - The `## Wikilinks` section MUST include `[[findings-master-index]]` and each individual `[[FND-XXXX]]` referenced in the session.
    - This enables bidirectional navigation: session doc → finding detail file → master index, and reverse lookups via Obsidian backlinks.
    - Any session doc missing these cross-references is a hygiene violation.

---

## G2. Mandatory Pre-Pause / Pre-Close Documentation Gate

**Effective date:** 2026-03-20

When Jimmy signals ANY form of work stoppage — pause, break, day close, or period transition — the agent MUST execute the applicable checklist BEFORE acknowledging the pause. This is non-negotiable. The agent does NOT wait for Jimmy to ask "any drifts?" — the gate fires automatically.

**Trigger phrases (any variant, English or Portuguese):**
- "let's stop here" / "vamos parar aqui"
- "let's take a break" / "vamos fazer uma pausa"
- "closing for today" / "encerrando por hoje" / "por hoje é isso"
- "that's enough for now" / "por enquanto é isso"
- "I'm going to rest" / "vou descansar"
- "let's pause the project" / "vamos pausar o projeto"
- **"save" / "salva" / "salvar"** — triggers lightweight Save gate: update all project docs + session doc + portfolio, commit, push. No checklist, no report — just execute and confirm with one line.
- **"checkpoint"** — triggers Pre-Pause gate (PP-01 through PP-08, PP-10). Also valid as a **Pre-Start gate** at session beginning to verify state left by previous sessions (PP-04 and PP-05 are N/A in Pre-Start context since no current session doc exists yet)
- **"close day" / "call it a day" / "call the day" / "day close" / "end of day"** — triggers full Pre-Close gate (PP-01 through PC-11)
- Any indication that work is stopping, even temporarily

**Automated Enforcement (Claude Code only):** A `UserPromptSubmit` hook at `.claude/hooks/checkpoint-gate.sh` detects these three keywords (save, checkpoint, close day) and injects the applicable instructions as `additionalContext`. A second hook at `_skills/daily-doc-information/scripts/kickoff-doc-gate.sh` detects "kickoff-doc" / "/kickoff-doc" and injects session-creation + project-handoff instructions. Codex and Gemini agents must detect keywords manually and follow the same protocol. A mechanical verification script at `_skills/daily-doc-information/scripts/checkpoint-verify.sh` handles PP-06, PP-07, and PP-10 checks for checkpoint/close-day gates.

### Kickoff-Doc Protocol (session opening gate)

**Trigger:** `/kickoff-doc`, `kickoff-doc`, or `kickoff doc` in a user message.

**Required inputs (MUST ask if missing):** session_id, agent_name, model.
**Optional input:** project_name.

**Protocol:**
1. Validate required inputs — if session_id, agent_name, or model are missing, ask Jimmy before proceeding.
2. Create a new session doc from the DDI template in `ai-sessions/YYYY-MM/`.
3. If a project is specified: read all project docs (PROJECT_CONTEXT, status-atual, next-step, decisoes), find the most recent session doc for that project, compare for drift, report drift, and create a complete handoff section.
4. If no project: create a General-context session doc with no drift check.
5. Set status to `in_progress` with real system clock timestamp.

**Full protocol reference:** `_skills/daily-doc-information/scripts/kickoff-doc-protocol.md`

### Pre-Pause Checklist (9 items — mandatory for ANY pause)

The agent must verify ALL of the following and report the result to Jimmy:

| # | Check | What to verify |
|---|---|---|
| PP-01 | Project status current | Every referenced project's `status-atual.md` reflects reality (correct phase, completed items, in-progress items, blockers) |
| PP-02 | Next step current | Every referenced project's `next-step.md` reflects the actual next action, not a stale previous step |
| PP-03 | Decisions registered | Every referenced project's `decisoes.md` has all decisions from this session |
| PP-04 | Session snapshot current | Session doc `Current Snapshot` matches actual state (active block, next action, blockers) |
| PP-05 | History complete | Session doc `Modification History` has a row for the current block of work |
| PP-06 | Findings counters match | `findings-master-index.md` frontmatter counters match actual table data |
| PP-07 | Findings flag correct | Session doc `has_findings` flag matches whether findings exist in the session |
| PP-08 | No stale values | No outdated percentages, scores, phase names, or status values anywhere |
| PP-10 | Stale sessions closed | No session docs from previous sessions still in `status: in_progress` with `closed_at_local: pending`. Current session excluded. Stale sessions MUST be closed before confirming checkpoint. |

> **Note:** PP-09 (wikilink orphans) was retired on 2026-03-24. The orphan detector remains available as a standalone tool (`_skills/daily-doc-information/orphan-detector.sh`) but no longer blocks checkpoint gates.

### Pre-Close Checklist (extends Pre-Pause — mandatory for day close / session close)

All 9 Pre-Pause checks, PLUS:

| # | Check | What to verify |
|---|---|---|
| PC-09 | Handoff populated | Session doc Handoff section fully filled (where stopped, where to resume, what not to reopen, files to read) |
| PC-10 | Clean-state gate | All DDI clean-state criteria (CS-01 through CS-08) evaluated |
| PC-11 | Daily report | Created if applicable (end of day) |

### Gate Execution Protocol

**ALL 6 steps below are NON-NEGOTIABLE. An agent MUST NOT stop at any intermediate step. Skipping any step — especially Step 6 — is a discipline failure (see FND-0050, R-21).**

1. Agent detects pause/close intent in Jimmy's message
2. Agent executes the applicable checklist (Pre-Pause or Pre-Close)
3. Agent reports results to Jimmy in a compact table: `PP-01: PASS`, `PP-02: PASS`, etc. **Include git working tree status** (dirty file count from `git status --short`)
4. If ANY check is `FAIL`: agent fixes the drift BEFORE confirming pause
5. After all checks pass: agent confirms "Gate PASSED — safe to pause/close"
6. **Agent checks `git status`, commits relevant changes, and pushes.** This step is MANDATORY — a checkpoint with uncommitted changes is INCOMPLETE. Each agent commits only their own session's changes.

**Prohibited behavior:**
- An agent must NEVER say "everything looks good" or "ready to close" without having executed ALL 6 steps. Blanket confirmation without itemized evidence is a hygiene violation.
- An agent must NEVER report checkpoint results without including git tree status. A clean checklist with a dirty tree is a false positive (FND-0050).

---

## H. Proactive Reminder Cadence

Conditional reminders only — maximum **one per skill per phase or milestone**. No spam.

| Skill | When to remind |
|---|---|
| `claude-session-registry` | When the session has accumulated relevant work or is nearing closure |
| `context-guardian` | When the session is long, context is heavy, or compaction is needed |
| `docx-indexer` | When new relevant documents were created and indexing would add clear value |

Other sibling skills (`token-economy`, `session-memoria`, `x-mem`, `pbi-claude-skills`) do not have proactive triggers.

Rules:
- Do not repeat a reminder unless the relevant state has changed.
- Prefer conditional triggers over fixed intervals.

---

## I. Power BI / DAX Domain Overlay

For Power BI / DAX rules, see sibling skill `pbi-claude-skills`. Activate when working on DAX measures or Power BI projects.

---

## J. Skill Evolution Governance

- New **universal preferences** enter this file.
- **Domain-specific preferences** go to a domain overlay or a dedicated skill.
- Every relevant change requires: version bump, CHANGELOG entry, and hub sync.
- This skill must remain readable and loadable at low cognitive cost.
- Do not embed detailed workflows that belong to sibling skills.

**Sibling skills to route to (do not duplicate their logic here):**
`claude-session-registry` | `context-guardian` | `docx-indexer` | `token-economy` | `session-memoria` | `x-mem` | `pbi-claude-skills` | `daily-doc-information` | `agent-orchestration-protocol`

---

## K. Documentation Language Standard

**Effective date:** 2026-03-19

All documents and artifacts generated by any agent — including but not limited to session docs, daily reports, project docs (PROJECT_CONTEXT.md, status-atual.md, next-step.md, decisoes.md), audit artifacts, planning docs, specs, prompts, and any other documentation — **must be written in American English**.

**Scope:**
- This rule applies to ALL agents (Claude, Codex, Gemini, and others) across ALL projects
- This rule applies to ALL document types, templates, and generated artifacts

**Exceptions:**
1. **User interactions:** Conversations in chat windows may remain in Portuguese or any language Jimmy prefers
2. **Dates and times:** Continue using Brazilian format (dd/mm/yyyy when displayed, YYYY-MM-DD in filenames/frontmatter) with America/Sao_Paulo timezone
3. **Existing documents:** Documents created before 2026-03-19 retain their original language — do not retroactively translate them
4. **Proper nouns and identifiers:** Brazilian place names, machine names, user names remain as-is (e.g., "Brasilia, Brasil")
5. **Updating existing documents:** When adding new content to a document created before 2026-03-19, write the new content in American English. The original content retains its language. Bilingual documents are acceptable during the transition period.

6. **Legacy operational filenames:** The project operational files `status-atual.md`, `decisoes.md`, and `next-step.md` retain their current names for backward compatibility across all existing projects and DDI templates. A migration to English equivalents (`current-status.md`, `decisions.md`) is planned as a separate DDI initiative. Until that migration completes, both naming conventions are valid.

**Non-negotiable:** No agent may generate new documentation artifacts in Portuguese from 2026-03-19 onward, regardless of the conversation language.

---

## L. AOP Dispatch Guardrails

**Effective date:** 2026-03-19

When any agent acts as an orchestrator and dispatches headless sessions via AOP:

1. **Always use the dispatch script.** Never invoke the target CLI directly. The scripts have the correct flags baked in:
   - `bash scripts/aop-codex-dispatch.sh <prompt> <artifact> [workdir]`
   - `bash scripts/aop-claude-dispatch.sh <prompt> <artifact> [workdir] [model]`
   - `bash scripts/aop-gemini-dispatch.sh <prompt> <artifact> [workdir] [model]`
   Scripts are located in `claude-intelligence-hub/agent-orchestration-protocol/scripts/`.

2. **Never dispatch from memory.** CLI flags change between versions. A single wrong flag wastes 10,000+ tokens per failed dispatch. With parallel dispatches, this scales to 100,000+ tokens burned.

3. **If no dispatch script exists** for the target agent, read the AOP SKILL.md Launch Commands table. Copy the exact command. Do not improvise.

4. **Prompt must be file-based.** Save the prompt to a `.md` file first, then pipe it to the dispatch script. Never use inline prompts for complex tasks.

5. **If a dispatch script fails** (error, permissions, wrong model ID), check the script exists and has execute permission. Verify model IDs against the LLM Model Selection Guide. Do not fall back to manual CLI invocation.

This rule applies to ALL agents acting as orchestrators — Magneto, Emma, Gemini, or any other.

---

## M. Minimum Viable Config for Agent Files

Each agent configuration file (CLAUDE.md, AGENTS.md, GEMINI.md) MUST contain at minimum these elements to function as a standalone fallback when this skill fails to load:

1. **Operating posture summary** — radical honesty, anti-yes-man, mandatory counterpoint (Section B core)
2. **Communication compression** — short by default, artifacts as files (Section C core)
3. **Workspace structure** — base paths for all 3 layers
4. **Skills routing** — pointer to `HUB_MAP.md` with absolute path
5. **Session close protocol** — mandatory project sync rule (Section G rule 13)
6. **Documentation language** — American English mandate with pointer to Section K
7. **Wikilink hygiene** — no orphaned files with pointer to Section F

Agent-specific content (tool mapping for Gemini, `<INSTRUCTIONS>` wrapper for Codex) is added on top of this baseline.

---

## N. Email Notification Triggers

When Jimmy says any of these phrases (English or Portuguese), the agent must send an email notification at the end of the current task:

- `email me when done` / `send completion email` / `send an email at the end`
- `me avise por email no final` / `me manda um email` / `manda email quando terminar`

**Implementation:** Use the `codex-task-notifier` skill. The notification script is at `C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1`. Refer to the skill for parameters and transport configuration.

**Rules:**
- Keep the main task as priority 1. Send the email only after the task is fully finished.
- Use a short task title and a 2-3 line summary in English unless Jimmy asks otherwise.
- This applies to ALL agents, not just Codex.
- If Jimmy explicitly says `via Microsoft` or equivalent, this section no longer owns the transport decision. Route the request to `microsoft-mail-deliver` instead of `codex-task-notifier`.

---

## O. Universal Skill Usage Guide

When working with skills from `C:\ai\claude-intelligence-hub`:

1. **Discovery:** Read `HUB_MAP.md` at `C:\ai\claude-intelligence-hub\HUB_MAP.md` for the full skill catalog.
2. **Trigger rules:** If Jimmy names a skill or the task clearly matches a skill's description, use that skill. Multiple mentions mean use them all. Do not carry skills across turns unless re-mentioned.
3. **Missing/blocked:** If a named skill is not found or cannot be read, say so briefly and continue with the best fallback.
4. **How to use a skill:**
   - Open its `SKILL.md`. Read only enough to follow the workflow.
   - Resolve relative paths from the skill directory.
   - If scripts exist, prefer running them over retyping code blocks.
   - If templates exist, reuse them.
5. **Context hygiene:** Keep context small — summarize long sections instead of pasting. Only load extra files when needed.
6. **Safety:** If a skill cannot be applied cleanly, state the issue, pick the best alternative, and continue.

---

## P. CEM Protection — JSON and Skin Edits are Destructive Actions

CEM (Canvas Element Map) JSON files and Skin baselines are the **source of truth** for BI dashboard designs in bi-designerx projects. Modifying them is classified as a **destructive action**.

**Rules (non-negotiable, all agents, all machines):**

1. **NEVER modify** a CEM JSON file (`bidx-cem-*-v*.json`) or Skin baseline (`bidx-cem-*-v*.0.md`) without Jimmy's **explicit approval for that specific modification**.
2. This applies to ALL versions (v2, v3, vN), whether `locked: true` (permanent, per Decision 12) or `locked: false` (active development).
3. Approval does NOT carry over between operations — each modification requires fresh approval.
4. DRAFT-OWNER files (`*-DRAFT-OWNER.md`) are **NOT protected** — they are disposable working copies, freely editable.
5. If you are unsure whether an operation will modify JSON or Skin, **ask Jimmy first**.
6. Creating a new JSON for the first time (new version) also requires Jimmy's explicit approval.

**Context:** FND-0019 (2026-03-21). The Version Lock Protocol (Decision 12) only seals permanently locked versions. During active development, JSON and Skin had zero protection. This rule closes that gap. See bi-designerx Decision 16.

---

## Q. CEM JSON Generation — Paper Scan Mandatory

**Effective date:** 2026-03-23

CEM JSON files MUST be generated exclusively via real-time Paper MCP scan. NEVER from memory, mental models, cached data, or manually compiled element lists.

**Rules (non-negotiable, all agents, all machines):**

1. Before generating any CEM JSON, perform a COMPLETE Paper MCP scan: `get_children` + `get_computed_styles` + `get_node_info` for EVERY element.
2. Every element's `active` flag must reflect its ACTUAL visibility in Paper (`isVisible` from `get_node_info`).
3. Every element's position (x, y, w, h) must come from `get_computed_styles`, not from session memory.
4. If Paper MCP is unavailable, BLOCK JSON generation. Do not fall back to memory-based generation.
5. This rule applies to ALL CEM versions (locked or unlocked) and ALL agents.

**Context:** FND-0023 (2026-03-23). CEM JSON v4 was generated from agent memory instead of a Paper scan. Elements had incorrect `active` states and potentially wrong positions. DRAFT derived from bad JSON induced agents to make unwanted modifications. See Decision 13 P4 gate.

---

## R. Learned Rules from Field Experience

**Effective date:** 2026-03-23

Rules learned from real failures, user corrections, and operational incidents. Each rule is battle-tested — it exists because an agent violated it at least once and caused harm.

**Governance:** When ANY agent receives behavioral feedback from Jimmy (corrections, "don't do X", "always do Y"), the feedback MUST be added here as a new rule. Memory-only feedback (Claude Code auto-memory, Gemini context, Codex notes) is insufficient — it does not cross agent boundaries. This section is the canonical, cross-agent source of truth for behavioral rules.

### R-01. Never Fabricate Email Addresses
**Origin:** FND — Magneto sent email to wrong address derived from OS username.
**Rule:** NEVER guess or derive email addresses. Always check `codex-task-notifier` SKILL.md Transport Routing section. Canonical recipient: `<DEFAULT_RECIPIENT>`. If unsure, ask Jimmy.
**Related:** Section N

### R-02. Always Read Skill Before AOP Dispatch
**Origin:** 2026-03-19 — Magneto failed 2 Codex dispatches guessing CLI flags from memory.
**Rule:** ALWAYS read the AOP SKILL.md Launch Commands table before ANY headless dispatch (`claude -p`, `codex exec`, `gemini -p`). Use dispatch scripts when available (`aop-codex-dispatch.sh`). Never improvise flags from memory.
**Related:** Section L

### R-03. Checkpoint After Each Delivery
**Origin:** Crash during accumulated work caused drift that required re-explanation.
**Rule:** After EACH completed task/round: (1) update project docs, (2) update session doc, (3) commit, (4) push. Only then start the next task. Never accumulate.
**Related:** Section G, rule 13

### R-04. Findings Dual Counter Sync
**Origin:** FND-0018 — Counters drifted because only one location was updated.
**Rule:** `findings-master-index.md` has counters in BOTH frontmatter AND Summary table. When ANY finding changes status, update BOTH atomically in the same edit session.
**Related:** Section G, rules 15-19

### R-05. Codex Defaults to PowerShell on Windows
**Origin:** 2026-03-18 — 7/140 commands failed silently due to PowerShell escaping. Updated 2026-03-27 — FND-0045 confirmed PowerShell strips double quotes from bash heredoc, corrupting JSON artifacts.
**Rule:** Every AOP prompt dispatched to Codex MUST include: "Use Git Bash (bash), NOT PowerShell. Write files using `cat > file << 'EOF'` syntax, never PowerShell `Set-Content`." **CRITICAL addition (AOP v4.1.0):** For JSON artifact generation, always use Python `json.dumps()` — never bash heredoc. The `aop-codex-dispatch.sh` script auto-injects this reminder. Also applies to Gemini if it defaults to PowerShell.
**Related:** Section L, AOP SKILL.md "Python-Based Artifact Generation"

### R-06. rm -rf Blocked — Use find -delete
**Origin:** Claude Code blocks `rm -rf` even with bypass permissions enabled.
**Rule:** Never use `rm -rf` or `rm -f` with wildcards. Use `find /path -type f -delete` instead. Never tell user "permission denied" — use the alternative immediately.
**Related:** Tool safety

### R-07. NotebookLM Infographic Rate Limit
**Origin:** FND-0008 — 5 infographics in sequence triggered 24h+ block.
**Rule:** Never batch-generate infographics. Max 1 at a time, evaluate, do other work, then generate next. Conservative limit: ~5-6/day with spacing. Other artifact types can still be generated while infographics are blocked.
**Related:** NotebookLM operations

### R-08. NotebookLM On-Demand Generation Only
**Origin:** 2026-03-22 — SKILL.md review revealed agents proactively generating extras.
**Rule:** Generate ONLY the exact artifact type and exact quantity the user explicitly requests. "1 infographic" = 1 infographic, nothing else. Never assume "generate all."
**Related:** NotebookLM operations

### R-09. Paper Design — No Frames Architecture
**Origin:** FND-0015 — Flex frames lock child positioning, making manual adjustments impossible.
**Rule:** NEVER use frames/containers/groupings in Paper.design. ALL elements must be direct children of the artboard with `position: absolute` + explicit `left`/`top` pixel values + unique `layer-name` with prefix convention (`bg_`, `icon_`, `title_`, `lgd_`, etc.). Artboard must use `display: block`, not flex.
**Related:** Section P

### R-10. Paper MCP Relative Coordinates
**Origin:** FND-0022 — CSS overrides in Paper are parent-relative, not artboard-absolute.
**Rule:** NEVER apply artboard-absolute coordinates directly via `update_styles`. Convert first: `css = json_absolute - parent_content_origin`. NEVER use `unset` — it destroys positioning permanently. Always check `parentId` via `get_node_info` and verify with `get_computed_styles` first.
**Related:** Section P

### R-11. Project Assets Are Documental
**Origin:** Architecture decision — assets must be isolated per project.
**Rule:** Assets (images, icons, logos) go in `obsidian/CIH/projects/{project}/assets/`, not shared across projects. Sandbox/dev uses `_skills/bi-designerx/assets/`. Real projects use the documental layer.
**Related:** Section D

### R-12. Session Terminology
**Origin:** 2026-03-16 — Formalized distinction to prevent confusion.
**Rule:** "Documento de Sessão" = the `.md` log file (one per day/agent/project, same Session ID all day). "Sessão de Trabalho" = physical chat window (multiple per day, each has own resume ID). When switching chats same day: keep same doc, register work session IDs in tracking table.
**Related:** Section G

### R-13. Never Dump Files in Repository Root
**Origin:** FND-0025 — Playwright screenshots and test outputs dumped in `C:\ai\` root, polluting the workspace.
**Rule:** NEVER create files in the repository root (`C:\ai\`). ALL generated artifacts (screenshots, test outputs, scripts, temp files) MUST go to the appropriate project directory: `_skills/<project>/` for skill technical artifacts, `projects/<project>/` for non-skill technical artifacts. When using tools that default to CWD output (Playwright, pandoc, etc.), ALWAYS specify an absolute path in the project directory. If unsure where a file belongs, ask Jimmy.
**Related:** Workspace hygiene

### R-14. Email Sending — 3-Tier Pipeline (gws CLI Default)
**Origin:** FND-0027 (MCP auth unreliable), FND-0028 (gws CLI invisible), FND-0033 (HTML as raw text — missing `--html` flag). Reordered 2026-03-24: gws CLI promoted to Tier 1 (most reliable).
**Rule:** gws CLI is the DEFAULT email method. Always use `--html` flag when body contains HTML. Fall through tiers on failure.

**Fallback order:**
1. **Tier 1 — gws CLI (DEFAULT):** `gws gmail +send --to <DEFAULT_RECIPIENT> --subject "Subject" --body "<p>Body</p>" --html` — authenticated as <GWS_AUTH_EMAIL>. **CRITICAL: `--html` flag is mandatory for HTML content.** Without it, tags render as visible text. Check auth: `gws auth status`.
2. **Tier 2 — Resend CLI:** `resend emails send --api-key $CTN_RESEND_API_KEY --from "<SENDER_EMAIL>" --to <DEFAULT_RECIPIENT> --subject "Subject" --html "<p>Body</p>"`.
3. **Tier 3 — Mailgun:** Via codex-task-notifier PowerShell pipeline (`send-manual-notification.ps1`). Mailgun is the last-resort fallback.
4. If all three fail → report failure with all attempted methods

**Note:** GWS Gmail MCP is NOT part of the fallback pipeline (OAuth unreliable, no CLI re-auth). May be used opportunistically if available, never as a planned tier.

**Email templates:** 5 HTML reference templates at `claude-intelligence-hub/codex-task-notifier/examples/` (executive-summary, table-report, status-update, project-portfolio, finding-alert). Agents MUST use these as the visual standard.

**How to apply:** Default to gws CLI for all emails. Only fall to Resend if `gws auth status` shows expired token. Mailgun only if Resend also fails. Always reference email templates for consistent formatting.
**Related:** Section N, FND-0027, FND-0028, FND-0033

### R-15. Email HTML Format — Mandatory Visual Standard
**Origin:** FND-0033 — Agents sending raw unformatted HTML or plain text. Jimmy requires clean, professional, readable emails.
**Rule:** ALL HTML emails MUST follow the codex-task-notifier email template visual standard. No exceptions.

**Mandatory elements:**
- Wrapper: `font-family: 'Segoe UI', Arial, sans-serif; max-width: 680px; margin: 0 auto; color: #2d2d2d`
- Title: `h2` with `color: #1a1a2e; border-bottom: 3px solid #e63946`
- Tables: `border-collapse: collapse`, header row `background: #1a1a2e; color: white`, alternating rows `#f8f9fa`, borders `1px solid #dee2e6`
- Footer: `hr` with `border-top: 2px solid #e63946`, then `font-size: 12px; color: #888` with agent + session + date
- Use `--html` flag with gws CLI or wrapper script `send-email.sh`

**Wrapper script:** `bash _skills/codex-task-notifier/scripts/send-email.sh --to X --subject Y --body "<html>"` — enforces `--html` automatically.
**Templates:** 5 reference templates at `claude-intelligence-hub/codex-task-notifier/examples/`.
**How to apply:** Before sending any HTML email, check the inline format reference in CLAUDE.md/AGENTS.md/GEMINI.md. For complex emails, read the full template from `examples/`.

### R-16. "Via Microsoft" Means microsoft-mail-deliver Protocol
**Origin:** 2026-03-26 - Jimmy defined a cross-agent shorthand after `microsoft-mail-deliver` became the active Microsoft sender path.
**Rule:** When Jimmy says phrases like `via Microsoft`, `do Microsoft`, `manda email pelo Microsoft`, `manda email do up4a`, or equivalent, agents MUST route the request through `microsoft-mail-deliver` and MUST NOT ask whether Gmail/Resend/Mailgun should be used. The transport choice is already made: use the Microsoft protocol. Only ask follow-up questions if recipient, content, or send conditions are genuinely missing.
**Related:** `microsoft-mail-deliver`, Section N

### R-17. Outbound Business Email Contract on Jimmy's Behalf
**Origin:** 2026-03-26 - Jimmy defined a mandatory composition contract for business emails sent by agents on his behalf.
**Rule:** When an agent drafts or sends a business email for Jimmy (not a task-end self-notification), the email MUST follow this contract:

- `To`: use exactly the recipient(s) Jimmy provides
- `Cc`: ALWAYS include `<CORPORATE_EMAIL>` for every recipient, every transport, every send, with no exceptions
- title/subject: Jimmy must define it; if missing, do NOT send; always convert the final subject to uppercase
- opening: mandatory time-of-day salutation plus `Agente <name>, <platform>, <LLM model>`
- intro: mandatory line stating the email is being sent at Jimmy's request and replies should go to `<CORPORATE_EMAIL>`
- body style: formal, professional, executive, short, direct, simple vocabulary, no rambling
- signature: `Atenciosamente,` then `Agente <name>, <platform>, <LLM model>` then `On behalf of Jimmy`

Do not improvise missing title, remove the mandatory CC, substitute alternate CC recipients, or use a casual tone. This rule applies regardless of transport. It complements `microsoft-mail-deliver` and does NOT replace the task-end notifier rules in Section N / R-14 / R-15.
**Related:** `microsoft-mail-deliver`, Section N, R-14, R-15

### R-18. Microsoft Recipient Registry Is Persistent Operational State
**Origin:** 2026-03-26 - Jimmy explicitly required Microsoft recipient add/list/delete behavior to be encoded into the skill instead of repeated ad hoc in chat.
**Rule:** When Jimmy asks to add, list, remove/delete, update, or reuse Microsoft business-email recipients, agents MUST use the `microsoft-mail-deliver` known-recipient registry at `C:\ai\_skills\microsoft-mail-deliver\data\known-recipients.json` through `scripts\manage-known-recipients.ps1`. The chat-display format for that list is fixed: numbered, alphabetical, markdown table with Enabled and Level columns. When Jimmy asks to send to everyone already saved, agents MUST resolve the selector `all` / `known:all` instead of making Jimmy retype every address. Registry v1.1.0 adds `enabled` (boolean) and `level` (`operational`/`middle`/`high`) fields per recipient. Use `-Action Update -Emails <email> -Enabled $true/$false -Level <level>` to change status.
**Related:** `microsoft-mail-deliver`, R-16, R-17

### R-19. Microsoft Email Safety Gates (FND-0048)
**Origin:** FND-0048 — Agent used `known:all` without Jimmy's explicit approval, sending an internal AI test report to 8 business contacts. Additionally, HTML body rendered as raw text due to missing ContentType detection.
**Rule:** Six non-negotiable safety mechanisms for `microsoft-mail-deliver`:
1. **`known:all` BLOCKED by default.** The known-recipients list may ONLY be used when Jimmy **explicitly and literally** writes "send to the list" / "send to all" / "known:all" in the current message. Script enforces: `send-microsoft-mail.ps1` blocks without `-ConfirmKnownAll` switch. **Second layer (v1.1.0):** Even when `-ConfirmKnownAll` is passed, recipients with `enabled: false` are automatically excluded from the resolved list. Only `enabled: true` recipients receive batch emails. Direct targeting of a specific disabled email still works (explicit choice).
2. **Default recipient = `<MICROSOFT_RECIPIENT>`** (Jimmy's own Microsoft email). If Jimmy does not specify a recipient, use this. NOT `<DEFAULT_RECIPIENT>` (that belongs to codex-task-notifier). Each skill has its own default.
3. **Title is mandatory.** If Jimmy does not provide a title/subject, the agent MUST ask. Do NOT fabricate.
4. **Pre-send confirmation required.** Before sending, show `To`, `Subject`, body preview. Wait for Jimmy's "ok" / "dispara" / "go". Exception: Jimmy pre-authorizes in the same message where he defines all parameters.
5. **HTML auto-detection.** `send-microsoft-mail.ps1` now auto-detects HTML tags in Body and promotes `BodyContentType` from `Text` to `HTML`.
6. **Skill exclusivity.** "Via Microsoft" = `microsoft-mail-deliver` only. If not available, do NOT send via other transports. Report failure.
**Why:** Agent discipline failure caused unauthorized email blast to business contacts. These gates prevent recurrence at both script and agent level.
**How to apply:** Before any `microsoft-mail-deliver` send, verify: (a) recipient is explicitly authorized, (b) title is Jimmy-provided, (c) summary shown to Jimmy. Default to `<MICROSOFT_RECIPIENT>` when no recipient specified.
**Related:** `microsoft-mail-deliver`, R-16, R-17, R-18, FND-0048

### R-20. Autoresearch Patterns — Git-as-Memory, Experiment Commits, Guard Pattern
**Origin:** Autoresearch deep analysis (generalx project, session c7bb66df, 2026-03-27). Three patterns extracted from the autoresearch skill for cross-agent adoption.
**Rule:** Three patterns for iterative development:
1. **Git-as-Memory:** Before starting work on any development task, read `git log --oneline -20` and check for reverted experiments. Use history to avoid repeating failed approaches.
2. **Experiment Commit Convention:** Use `experiment(<scope>): <description>` for exploratory changes. Kept experiments = commit stays. Discarded = `git revert` (preserves attempt in history as learning signal).
3. **Guard Pattern:** When modifying code, define a METRIC (primary goal) and a GUARD (safety check). Keep changes only if BOTH pass. Never modify guard/test files during the optimization loop.
**Why:** Agents without historical context repeat failed approaches across sessions. Experiment commits create machine-readable learning signals. Guard pattern prevents regression during optimization.
**How to apply:** Orchestrators include git-as-memory instructions in AOP dispatch prompts. All agents use experiment commit convention during development. Guard pattern applies to any code modification task.
**Related:** AOP SKILL.md v4.2.0 Prompt Guidance sections, generalx Autoresearch analysis report

### R-21. Checkpoint Gate Must Be Executed Completely — ALL Steps Non-Negotiable
**Origin:** FND-0050 (2026-03-28). Agent (Magneto) ran checkpoint but stopped at Step 3 (report table), skipping Step 4/6 (git status + commit/push). Jimmy discovered 50+ dirty files that should have been reported.
**Rule:** When executing any checkpoint/save/close-day gate, ALL protocol steps must be completed without exception. No step is optional. Specifically:
1. Run mechanical verification script
2. Perform semantic checks (PP-01 through PP-08, PP-10)
3. Report results including git tree status (dirty file count)
4. Fix all FAILs
5. Confirm gate status
6. Check `git status`, commit relevant changes, push
Stopping at any intermediate step is a discipline failure. A checkpoint with uncommitted changes is INCOMPLETE — it is a false positive that blinds the user.
**Why:** Checkpoint gates exist to give Jimmy full visibility into system state. Skipping the git status check means accumulated dirt from other agents/sessions goes undetected. Jimmy cannot trust "all PASS" if the tree is dirty.
**How to apply:** Every agent, every checkpoint, every time. The mechanical script now includes a git status check (FND-0050 fix), but agents must also commit/push — the script is read-only.

### R-22. Thread Read Receipt Timestamps Must Come from System Clock
**Origin:** FND-0052 (2026-03-28). Agent (Magneto) wrote read receipt timestamps by guessing instead of capturing from `date` command. Multiple timestamps off by over an hour in hr_kpis_board thread doc.
**Rule:** When writing a read receipt (`✅ read-YYYY-MM-DD-HH:MM-{reader-name}`), the timestamp MUST be captured from the system clock by running `date "+%Y-%m-%d-%H:%M"` BEFORE writing the receipt. NEVER estimate, infer from context, or hardcode.
**Why:** Read receipts are the audit trail for when entries were actually read. Fabricated timestamps make the trail unreliable and mislead Jimmy about response times.
**How to apply:** Every agent, every read receipt, every time. Run `date` first, use the output. No exceptions.

### R-24. Orchestrator Must Independently Verify Sub-Agent Deliverables
**Origin:** FND-0054 (2026-03-29). Magneto accepted a sub-agent's self-reported "SUCCESS" for daily-reports grouping without independently verifying that files were actually moved. Jimmy discovered the gap.
**Rule:** When an orchestrator delegates a task via AOP dispatch or Agent tool, the orchestrator MUST independently verify the deliverables BEFORE reporting the task as complete to Jimmy. Never trust the sub-agent's self-reported status alone.
**Why:** Sub-agents can report success while partially completing work, skipping steps, or misunderstanding scope. The orchestrator is responsible for quality — not just dispatch.
**How to apply:** After every sub-agent/AOP task completion: (1) check the file system for expected changes, (2) run any applicable verification (integrity check, file count, diff), (3) only then report to Jimmy. This applies to ALL dispatch methods (Agent tool, AOP Codex, AOP Claude, AOP Gemini).

### R-23. Do Not Launch `claude -p` via Bash Tool Inside a Running Claude Code Session
**Origin:** FND-0053 (2026-03-29). AOP Claude headless dispatch (`aop-claude-dispatch.sh`) hung indefinitely when launched via the Bash tool inside an active Claude Code interactive session. The `claude -p` process started but produced zero output and never completed. The same script works perfectly when launched from a terminal, Codex, Gemini, or any other external context.
**Rule:** Do NOT run `aop-claude-dispatch.sh` (or any `claude -p` command) via the Bash tool inside a running Claude Code session. This is NOT a general ban on Claude-to-Claude AOP dispatch — that works fine when the dispatch originates from a terminal or another agent platform.
**Why:** The `claude -p` (stdin pipe mode) appears to conflict with the parent Claude Code process when launched as a child process. The exact mechanism is unknown (possible socket/lock conflict), but the behavior is reproducible.
**How to apply:** When orchestrating from Claude Code and needing Claude-side parallel execution: use the Agent tool (sub-agents) instead. The `aop-claude-dispatch.sh` script remains the correct choice when dispatching from a terminal, Codex, or Gemini.

### R-25. Timestamp Capture on Windows/Git Bash — No TZ Override
**Origin:** FND-0057 (2026-03-29). `TZ="America/Sao_Paulo" date` in Git Bash on Windows adds +3h instead of correcting. MSYS2 double-applies the timezone offset when the Windows clock is already in the correct timezone.
**Rule:** On Windows machines running Git Bash, ALWAYS capture timestamps with bare `date "+%Y-%m-%d-%H:%M"` — NEVER use `TZ=` prefix.
**Why:** The machine clock is already in the correct local timezone. The `TZ=` override causes MSYS2's `date` to treat the local clock as UTC and apply the offset again, producing timestamps +3h (or +Nh for other timezones) wrong.
**How to apply:** Every agent, every time a timestamp is needed — read receipts, session docs, daily reports, and any other time-sensitive operation. Canonical command: `date "+%Y-%m-%d-%H:%M"`.

### R-26. Project Lifecycle Is Mandatory — Discovery Before Implementation
**Origin:** FND-0058 + PROJECT_LIFECYCLE.md (2026-03-29). Agents were jumping straight to folder creation and implementation without conducting discovery interviews, writing specs, or creating execution plans. This resulted in incomplete project structures and missed requirements.
**Rule:** Every project MUST follow the lifecycle defined in `obsidian/CIH/projects/_templates/PROJECT_LIFECYCLE.md`. The 5 phases are: Phase 0 (Discovery/Brainstorming) → Phase 1 (SDD) → Phase 2 (DEP) → Phase 3 (Implementation with tests) → Phase 4 (Verification). No phase may be skipped. Jimmy approves every phase transition.
**Why:** Projects that skip discovery start with hidden ambiguities. Projects that skip specs get built wrong. Projects that skip plans get implemented inefficiently. Projects that skip testing ship broken.
**How to apply:** When Jimmy says "create a project", "new project", "I want to build X", or any equivalent — do NOT create folders or write code. Start Phase 0 Discovery with a structured brainstorming interview. Only proceed after Jimmy's explicit approval at each gate. Verify compliance with: `bash projects/scripts_bootstraps/project-lifecycle-verify.sh --project <path> --auto`.

### R-27. CEM .md Artifacts Must Be Mirrored to Obsidian for PBI Projects
**Origin:** FND-0062 (2026-03-30). CEM pack `.md` artifacts (Skin baseline, DRAFT-OWNER, Rationale) were stored only in `projects/[name]/artifacts/` and invisible to Obsidian graph.
**Rule:** For PBI projects, all `.md` pack artifacts MUST exist in BOTH locations: `projects/<project>/artifacts/<page>/` (technical) AND `obsidian/CIH/projects/<project>/05-final/artifacts/<page>/` (documental). Non-`.md` artifacts (JSON, PNG, PDF, HTML, XLSX) stay only in the technical layer.
**Why:** Obsidian graph visibility is essential for Jimmy's review and cross-referencing. Documents trapped in the technical layer are invisible to the knowledge system.
**How to apply:** After generating or recreating any `.md` CEM artifact, immediately copy it to the Obsidian mirror path. Both copies must stay in sync.

### R-28. DRAFT-OWNER Must Include Per-Section Comment Blocks
**Origin:** FND-0063 (2026-03-31). DRAFT-OWNER generated without per-section comment areas, preventing Jimmy from annotating during review.
**Rule:** Every DRAFT-OWNER file MUST include: (1) per-section `**[Section] notes/instructions:** <!-- -->` comment blocks after every section's tables, (2) `Changes` column in all element tables, (3) Visual Properties split per section, (4) How to Edit guide with examples, (5) General Notes section with placeholder.
**Why:** Jimmy needs structured annotation points during DRAFT review. A single "Notes" section at the end is insufficient for per-section feedback.
**How to apply:** Use `bidx-cem-people-overview-v1-DRAFT-OWNER.md` as the reference template. See SKILL.md Section 6.5 for full requirements.

### R-29. Interactive HTML Package is Mandatory for Every CEM Lock
**Origin:** Jimmy's feedback on workforce-view-v1 pack (2026-03-31). Jimmy: "Que trabalho FANTÁSTICO! Daqui pra frente quero isso pra todos os projetos de BI, Design, que envolver o Paper!"
**Rule:** The CEM HTML Package (artifact #7) MUST be generated for every locked CEM version. It is a non-negotiable deliverable — not optional, not agent-discretionary. Must be self-contained HTML with inline CSS/JS, zero external dependencies, interactive visual map with search/filter/hover/click.
**Why:** The HTML Package provides the highest-value review artifact for stakeholders. Jimmy explicitly mandated it as standard for all BI/Design projects involving Paper.
**How to apply:** After locking a CEM version, generate the HTML Package from the JSON. Use the workforce-view-v1 package as the reference template. See SKILL.md Section 6.3.

### R-30. Excel Script Must Use Dynamic Sections — Never Hardcode Page Structure
**Origin:** FND-0065 (2026-03-31). `generate-cem-excel.js` had hardcoded section filters for People Overview, causing Workforce View Excel to be generated with empty body tabs (120 elements missing).
**Rule:** The Excel generation script MUST auto-discover sections from JSON elements. Never hardcode section names. Color palette cells must include visual color swatches (filled cells).
**Why:** Different dashboard pages have different section structures. Hardcoded filters silently produce incomplete artifacts.
**How to apply:** Use `[...new Set(cem.elements.map(el => el.section))]` to discover sections dynamically. See FND-0065.

### R-31. Screenshot Export Must Be Autonomous — Never Ask Jimmy to Export Manually
**Origin:** FND-0066 (2026-03-31). Agent could not save Paper MCP `get_screenshot` to file (returns base64 inline only). Asked Jimmy to export manually. Jimmy pointed out Playwright can open Paper URL in browser and click the Export button.
**Rule:** Screenshot artifacts MUST be exported autonomously via Playwright + Paper UI Export button. The Paper file URL MUST be stored in `PROJECT_CONTEXT.md` at project setup. Agents MUST NOT ask the user to export manually — the full procedure is in SKILL.md Section 6.7.
**Why:** Agents should be self-sufficient for all pack artifact generation. Manual export is friction and breaks the autonomous pipeline.
**How to apply:** At project setup, store Paper file URL in PROJECT_CONTEXT.md. At screenshot export time, follow SKILL.md 6.7 step-by-step. If URL is missing, capture it via Playwright `window.location.href`.

### R-32. CEM Element Naming Must Cover ALL Tree Depths — No Generic Names Allowed
**Origin:** FND-0068 (2026-04-01). During P3 (Element Naming) for people-strategy-v1, agent only renamed top-level semantic containers (cards, titles, charts) but left 15 child elements with Paper auto-generated names ("SVG", "Rectangle", "Frame", bare year text). Jimmy caught the drift visually in Paper's layer tree.
**Rule:** During CEM P3 (Element Naming), the agent MUST rename ALL elements at ALL tree depths. This includes child SVGs inside icon backgrounds, child rectangles inside row containers, and child text labels inside composite frames. No element may retain Paper auto-generated names ("SVG", "Rectangle", "Frame", "Text", or bare content values). Exception: SVGVisualElement children inside chart/icon SVG composites (Path, Circle, Line, Polyline, data labels) are rendering primitives and are excluded from individual renaming.
**Why:** Generic names in the layer tree make it impossible for Jimmy to visually verify the mapping. It caused retracking, wasted tokens, and broke the "100% unique names" guarantee of P3.
**How to apply:** After renaming top-level elements, run `get_tree_summary` at depth 4+ and scan for ANY element still named "SVG", "Rectangle", "Frame", "Text", or a bare content value. Rename all of them before declaring P3 complete.

### R-33. Always Commit + Push After Completing Work — Never Wait for Jimmy to Ask
**Origin:** FND-0069 (2026-04-01). Jimmy had to repeatedly ask agents to commit and push after completing tasks. Memory-only rule discovered during checkpoint WARN audit.
**Rule:** After completing ANY body of work (updates, fixes, features, doc changes), ALWAYS commit and push immediately as the final step. The work is NOT "done" until it's committed and pushed. Never wait for Jimmy to request this.
**Why:** Uncommitted work is invisible work. If the session crashes, context switches, or another agent takes over, unpushed changes are lost. Jimmy should never have to say "commit + push" — it should be automatic.
**How to apply:** Treat `git add + commit + push` as the natural last step of every task. This complements R-03 (checkpoint after each delivery) and R-21 (complete gate execution) but goes further: it applies to ALL work, not just checkpoint gates.

### R-34. "Respondi" Means Jimmy Replied in the Thread Doc — Go Read It
**Origin:** FND-0069 (2026-04-01). Memory-only rule discovered during checkpoint WARN audit. Jimmy uses "Respondi" as shorthand across sessions.
**Rule:** When Jimmy says "Respondi" (or "respondi", "I replied"), it means he has written a new entry in the active project's thread document (`*-pjt-threads-jimmy-magneto.md`). Immediately read the thread doc, find his latest entry, add a read receipt, and act on instructions.
**Why:** Thread docs are Jimmy's primary async communication channel for project work. "Respondi" is established shorthand — no need to ask "where?" or "which doc?".
**How to apply:** On seeing "Respondi" → identify the active project → read `00_prompts_agents/*-pjt-threads-*.md` → find Jimmy's latest entry → add read receipt → execute.

### R-35. Do Not Include Other Sessions' Projects in Status Updates Unless Asked
**Origin:** FND-0069 (2026-04-01). Memory-only rule discovered during checkpoint WARN audit. Magneto was including bi-designerx updates in sessions where it wasn't the active scope, creating noise.
**Rule:** When listing next steps, project status, or planning session work, only include projects that are IN SCOPE for the current session. Do not bring unsolicited status from projects being worked on in other parallel sessions/agents.
**Why:** Jimmy runs multiple parallel sessions with different agents. Cross-pollinating status between sessions creates confusion and wastes context.
**How to apply:** Check the session doc's `project:` field and thread context. Only report on projects explicitly referenced in the current session unless Jimmy asks for a broader view.

### R-36. Active Timestamp Enforcement — Always Call `now.sh` Before Writing Any Timestamp
**Origin:** FND-0070 (2026-04-02). Recurrence of FND-0052 — agent fabricated read receipt time (09:55 vs actual ~10:15) despite R-15, R-22, PB-12 all being documented. Passive rules proven insufficient after 3+ occurrences.
**Rule:** Before writing ANY timestamp in ANY document (session doc, thread doc, read receipt, history row, frontmatter, finding), the agent MUST call `bash C:/ai/_skills/daily-doc-information/scripts/now.sh` (or the appropriate flag variant) and use the returned value verbatim. No exceptions. No estimation. No "I'll just type it."
**Why:** Timestamps are operational data used for audits, studies, and cross-session tracking. Fabricated timestamps corrupt the historical record. Three rounds of passive rules (R-15, R-22, PB-12) failed to prevent recurrence because they depend on agent memory at write-time.
**How to apply:** `now.sh` (default: `YYYY-MM-DD HH:MM`), `now.sh --receipt` (`YYYY-MM-DD-HH:MM` for read receipts), `now.sh --date`, `now.sh --time`, `now.sh --full`. Always run BEFORE the edit, never after.

### R-37. Close-Day Gate Must Produce a Canonical Daily Report — Path, Coverage, and Commit Verified Mechanically
**Origin:** FND-0075 (2026-04-08). Third recurrence of the "declared but not verified" anti-pattern (FND-0050, FND-0073, FND-0075). On 2026-04-07, Jimmy explicitly requested a close-day gate at 22:29. The agent acknowledged at 22:32 but the resulting commit contained zero daily-report or portfolio changes. A separate earlier gate the same day wrote 7 daily-report files into `ai-sessions/2026-04/` (wrong folder), bypassing the DDI skill's SC-09 OUTPUT_PATH_OUT_OF_BOUNDS check. The root cause in the passive gate instructions was literally telling agents to "Check ai-sessions/YYYY-MM/ for daily report" — the wrong path baked into the keyword hook itself.
**Rule:** A close-day gate is NOT complete until ALL four mechanical checks pass for the current day:
1. **Daily report exists at canonical path.** File must be at `obsidian/CIH/projects/skills/daily-doc-information/daily-reports/YYYY-MM/daily-report-executive-YYYY-MM-DD-v1.md` (or legacy `daily-report-YYYY-MM-DD.md` for pre-existing files). No orphan daily reports may exist in `ai-sessions/YYYY-MM/`.
2. **Coverage complete.** The daily report's Sessions Today table must list EVERY session doc with `closed_at_local` on that date. Missing any closed session is a gate failure.
3. **No SC-09 bypass.** Writes to daily-report files MUST go through the DDI skill's `create-daily-report` operation OR, if using Write directly, the agent must self-verify the output path is inside `daily-reports/YYYY-MM/` before writing. A pre-commit hook blocks any commit that stages a `daily-report-*.md` file outside the canonical path.
4. **Git commit exists for the gate.** A commit touching the daily report AND the closed session doc(s) AND (if any project status changed) the strategic-project-portfolio.md must exist for the day, with message containing "close-day" or equivalent.
**Why:** Close-day is the only end-of-day artifact with cross-session truth. Silent failures accumulate — a missed close-day gate leaves the day's work unverified and invisible to retroactive analysis. The declaration-without-execution pattern has failed three times under different scopes (session checkpoint, session field-level close, day-level close). Mechanical enforcement is the only remaining option.
**How to apply:** Run `bash C:/ai/_skills/daily-doc-information/scripts/close-day-verify.sh` as a mandatory check in the close-day keyword gate. The script must exit 0 before the agent may declare the gate complete. If it exits non-zero, the agent must fix every failing check and re-run the script. Report results as a compact table in the close-day confirmation message. The keyword hook `C:/ai/.claude/hooks/checkpoint-gate.sh` now injects the mandatory invocation instruction. A pre-commit hook (`_skills/daily-doc-information/scripts/hooks/pre-commit-daily-report.sh`, installed locally via `install-pre-commit.sh`) mechanically blocks SC-09 violations at commit time.

### R-38. Never Run Destructive Git Operations Without Listing Targets and Obtaining Explicit Authorization
**Origin:** FND-0077 (2026-04-08). Agent ran `git worktree prune` in the parent repo after cleaning up 12 legitimate worktrees. The prune command silently removed the `C:/ai/claude-intelligence-hub/` directory AND its `.git` because the hub had been cross-registered as a worktree of the parent repo by the FND-0076 AOP Phase 0 bug. Net effect: 223 MB of hub content and a local commit (b4732fa, the R-37 release) were deleted instantly. No explicit "rm" was ever typed. The agent did not predict this outcome because it did not verify what `prune` would touch before running it.
**Rule:** Before running ANY of the following git operations, the agent MUST list every target that will be affected AND obtain Jimmy's explicit authorization for that exact operation on that exact list:
- `git worktree prune` (can delete directories and .git contents when worktrees are cross-registered)
- `git gc --aggressive` or `git gc --prune=now`
- `git clean -fd` / `git clean -fdx`
- `git worktree remove --force <path>`
- `git reflog expire --expire-unreachable=now --all`
- `git update-ref -d <ref>`
- `rm -rf` targeting any directory inside `C:/ai/` (use `find -delete` with explicit starting path only)
- Any `find -delete` where the starting path contains symlinks, junctions, or nested `.git` directories

No exceptions. "Looks innocent" is not a pass. "Previous similar command worked" is not a pass. The listing step MUST happen even when you think the outcome is obvious.
**Why:** Destructive git operations have blast radius that depends on repository state you may not have fully inspected. `git worktree prune` was assumed safe because it "only cleans stale entries" — but a stale entry pointing at a valid directory WILL delete that directory. The cost of a 30-second authorization check is trivial; the cost of the hub disaster on 2026-04-08 was hours of recovery, lost local commits, and high stress for Jimmy.
**How to apply:** Before running any command in the list above, write in the conversation: "I am about to run `<exact command>`. This will affect the following paths/refs: `<listed targets>`. Confirm?" Wait for explicit approval. If Jimmy says anything other than "yes", do not proceed. Log the authorization in the session doc's modification history.

### R-39. Verify Worktree Registration in BOTH Parent and Hub Repos Before Any Worktree Operation
**Origin:** FND-0077 (2026-04-08). Same incident as R-38. The hub `C:/ai/claude-intelligence-hub/` was cross-registered as a worktree of the parent repo `C:/ai/.git/` because of an FND-0076 AOP Phase 0 bug. The agent did not detect this because it ran `git worktree list` only from inside the hub, saw 4 legitimate hub worktrees (run01-04), and assumed `_worktrees/si-repo-auditor-2026-04-07-run05` through run16 were also hub worktrees. They were actually parent-repo worktrees. The cross-registration of the hub itself was never inspected.
**Rule:** Before ANY worktree operation (`add`, `remove`, `prune`, `repair`, `move`) in a multi-repo workspace like `C:/ai/`, the agent MUST:
1. Run `git worktree list --verbose` from inside the parent repo (`C:/ai/.git/`) and record the output.
2. Run `git worktree list --verbose` from inside EACH nested repo (e.g., `C:/ai/claude-intelligence-hub/.git/`) and record each output.
3. Cross-reference: verify that each worktree path appears in exactly ONE repo's list. If a path appears in two lists, flag it as cross-registration drift (FND-0076 pattern) and STOP — do not proceed without resolving the drift first.
4. Verify that no nested repository directory (`claude-intelligence-hub/`, `_worktrees/*/`) is listed as a worktree of its parent repo. If it is, flag and STOP.
**Why:** Cross-registration is invisible drift that only surfaces when a destructive operation runs. Detecting it before the operation is trivial. Detecting it after is an incident.
**How to apply:** A reusable script `_skills/daily-doc-information/scripts/worktree-preflight.sh` runs the 4 checks. Invoke it before any worktree operation. If the script reports drift, STOP and report to Jimmy. Do not run any worktree command until drift is resolved. PP-14 in `checkpoint-verify.sh` runs this check at every checkpoint to catch drift proactively.

---

*Part of the [Claude Intelligence Hub](https://github.com/mrjimmyny/claude-intelligence-hub)*
