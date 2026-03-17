# AOP Reworking - Round 1: SKILL.md Unified Rewrite

## Your Role
You are an Executor Agent. Your job is to rewrite SKILL.md as the single authoritative document for AOP. Work ONLY in this directory: `C:\ai\_worktrees\aop-reworking\agent-orchestration-protocol\`

## DO NOT
- Modify ANY file outside this directory
- Create session docs (the Orchestrator handles all documentation)
- Delete any existing files (only modify SKILL.md)

## Context
AOP currently has a V1/V2 split that is confusing and non-functional. V2 (JSON schemas, Python engine) was never used in production. All real orchestrations use V1 CLI patterns. The decision has been made to UNIFY into a single AOP — no more "V1" or "V2" labels. One protocol.

## What To Do

Rewrite `SKILL.md` following these requirements:

### Structure (in this order)
1. **Header** — Name, version (bump to 3.0.0), status, description
2. **What AOP Is / What AOP Is NOT** — Immediately clarify: AOP = launching real OS processes via shell. Internal sub-agents (Agent tool) are NOT AOP. This is the #1 misconception. Put the comparison table HERE, not at the bottom.
3. **The Seven Pillars** — Keep all 7, but convert each to 3-part format: (a) Definition, (b) Implementation command/snippet, (c) Verification test. Make them an actionable checklist, not a manifesto.
4. **Security Boundaries** (NEW section) — Define:
   - What "trusted workspace" means concretely (path-based allow-list)
   - What bypass flags do and do NOT protect against
   - Mandatory `write_paths` declaration in every executor prompt
   - Post-execution verification recommendation (git diff against expected changes)
   - Explicit "DO NOT USE bypass for" list (production repos without review, system directories, credential stores)
5. **Execution Standard** — Keep the mandatory patterns but:
   - Standardize on bash as primary (it's what production uses)
   - Add PowerShell as alternative where needed
   - File-based prompt pattern as the RECOMMENDED default
   - Include cleanup protocol: delete prompt file + artifact after success
   - Include artifact naming with session_id for parallel safety
6. **Polling & Completion** — Merge all polling guidance into one section:
   - Artifact-based polling as the standard
   - Non-empty file check: `test -f FILE && test -s FILE`
   - Maximum poll count with explicit FAIL path
   - Adaptive intervals (30s for first 2min, then 60s)
   - PID capture at launch for timeout kill capability
7. **Error Recovery** (NEW section) — Simple playbook:
   - If timeout: kill process (document how), check partial results
   - If executor crash: check for error.json, decide retry or abort
   - If orchestrator crash: how to detect/kill orphaned processes
   - Rollback: when to use git stash vs file copy, who takes snapshot
8. **Governance (Lightweight)** — Practical audit trail:
   - Orchestrator logs key events to a simple JSONL file (not the full V2 audit system)
   - Minimum fields: timestamp, task_id, executor, status, files_changed
   - Guard rails as sensible defaults (timeout, require completion artifact)
   - Cost tracking: require self-report in completion artifact
9. **Cross-LLM Command Reference** — Updated table:
   - Remove unverified flags (Gemini -y alias)
   - Add Model Selection and Background Execution rows
   - Bash syntax primary, PowerShell noted as alternative
   - Add Known CLI Quirks sub-section
10. **Completion Artifact Schema** — Formalize:
    - Required fields: status, task_id, session_id, timestamp, executor, files_changed
    - Optional: findings_count, cost_tracking, error_details
    - Naming convention: `AOP_COMPLETE_{session_id_short}.json`
11. **Worked Examples Reference** — Brief pointer to AOP_WORKED_EXAMPLES.md (which will be updated in a later round)

### Key Writing Rules
- NO mention of "V1" or "V2" anywhere. It's just "AOP"
- Language: English, concise, direct
- Every instruction must be actionable — if you can't give a command, don't give a principle
- Use bash syntax for all examples (note PowerShell alternatives in parentheses)
- Include real absolute paths from the production environment: `C:\ai\` as base
- Keep Mermaid sequence diagram but update it to reflect unified flow
- Version: 3.0.0 (major bump — this is a breaking rewrite)
- Author: preserve original author (Forge) but add "Reworked by: Magneto, Agent Alpha, Agent Bravo"
- The skill frontmatter (name, version, description, command, aliases) MUST stay at the top

### What To Read First
Before writing, read these files in THIS directory to understand the current state:
1. `SKILL.md` — current version (you're rewriting this)
2. `README.md` — overlapping content to consolidate from
3. `AOP_WORKED_EXAMPLES.md` — understand the prompt patterns
4. `CHANGELOG.md` — understand version history

### Completion
When done:
1. Write the new SKILL.md (overwrite the existing one)
2. Run `date '+%Y-%m-%dT%H:%M:%S%z'` to get the real timestamp
3. Create completion artifact: `C:\ai\_worktrees\aop-reworking\agent-orchestration-protocol\AOP_ROUND1_COMPLETE.json`

```json
{
  "status": "SUCCESS or FAILURE",
  "task": "Round 1: SKILL.md Unified Rewrite",
  "timestamp": "REAL_TIMESTAMP_FROM_DATE_COMMAND",
  "executor": "Claude Sonnet 4.6 (headless AOP)",
  "files_changed": ["SKILL.md"],
  "summary": "Brief description of what was done"
}
```
