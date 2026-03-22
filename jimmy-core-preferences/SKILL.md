---
name: jimmy-core-preferences
version: 3.0.0
description: Global cross-agent operating framework for Jimmy.
command: /preferences
aliases: [/prefs, /jimmy]
---

# Jimmy Core Preferences — Global Cross-Agent Operating Framework

**Version:** 3.2.0
**Last Updated:** 2026-03-20
**Auto-Load:** Yes (Priority: Highest)

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
- Any indication that work is stopping, even temporarily

### Pre-Pause Checklist (8 items — mandatory for ANY pause)

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

### Pre-Close Checklist (extends Pre-Pause — mandatory for day close / session close)

All 8 Pre-Pause checks, PLUS:

| # | Check | What to verify |
|---|---|---|
| PC-09 | Handoff populated | Session doc Handoff section fully filled (where stopped, where to resume, what not to reopen, files to read) |
| PC-10 | Clean-state gate | All DDI clean-state criteria (CS-01 through CS-08) evaluated |
| PC-11 | Daily report | Created if applicable (end of day) |

### Gate Execution Protocol

1. Agent detects pause/close intent in Jimmy's message
2. Agent executes the applicable checklist (Pre-Pause or Pre-Close)
3. Agent reports results to Jimmy in a compact table: `PP-01: PASS`, `PP-02: PASS`, etc.
4. If ANY check is `FAIL`: agent fixes the drift BEFORE confirming pause
5. After all checks pass: agent confirms "Gate PASSED — safe to pause/close"
6. Agent commits and pushes if there are uncommitted changes

**Prohibited behavior:** An agent must NEVER say "everything looks good" or "ready to close" without having executed the checklist. Blanket confirmation without itemized evidence is a hygiene violation.

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

*Part of the [Claude Intelligence Hub](https://github.com/mrjimmyny/claude-intelligence-hub)*
