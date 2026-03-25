# Changelog — Agent Orchestration Protocol

## [4.0.1] - 2026-03-25

### Changed
- **Model Selection updated to v2.2.0** with official Codex model routing data (from official OpenAI/Codex source).
- **Cross-provider equivalence table** expanded from 3 tiers to 5 tiers: added Tier 1.5 (GPT-5.3-codex for multi-agent orchestration) and Tier 2.5 (GPT-5.1-codex for stability, GPT-5.1-codex-max for large context).
- **GPT-5.2-codex designated as official DEFAULT** model for Codex (was previously GPT-5.4 in dispatch script, GPT-5.3-codex in docs).
- **New models added:** `gpt-5.1-codex` (stability-focused), `gpt-5-codex-mini` (fast/cheap Tier 3).
- **Codex Execution Principles** added (6 official rules: analyze before selecting, prefer efficiency, upgrade only when justified, dynamic switching, etc.).
- **Mandatory post-AOP model reporting** requirement added — selected model + reason must be stated in session docs.
- **aop-codex-dispatch.sh** — Model parameter added (4th argument). Was hardcoded to `gpt-5.4`; now defaults to `gpt-5.2-codex` with override support. Matches Claude/Gemini dispatch script pattern.
- **Cross-LLM Command Reference** — Updated default model IDs: Codex `gpt-5.2-codex` (was `gpt-5.4`), Gemini `gemini-2.5-flash` (was `gemini-3.1-pro`/`gemini-3-flash`).
- **README.md** — Cross-LLM table expanded with default model row and model selection note.
- **AOP-EXECUTIVE-SUMMARY.md** — Supported CLIs table updated with default model row.

### Fixed
- **Gemini model IDs:** Fixed `gemini-3.1-pro` → `gemini-2.5-pro` and `gemini-3-flash` → `gemini-2.5-flash` in SKILL.md and launch command templates.
- **Codex dispatch default:** Fixed `gpt-5.4` (Tier 1) as default in `aop-codex-dispatch.sh` — should be `gpt-5.2-codex` (Tier 2) per official Codex routing.

## [4.0.0-rc.1] - 2026-03-18

### Added
- **Multi-Executor Coordination (C1)** — Pre-dispatch write path validation (pairwise disjoint check), executor isolation rules (`executor_id` format, artifact namespacing, no cross-reads), per-executor post-execution write scope audit.
- **Fan-In/Fan-Out Orchestration (C2)** — Fan-out protocol with task manifest and parallel dispatch, fan-in aggregation artifact (`AOP_FANIN_{session_id}.json`) with partial success handling (`SUCCESS`/`PARTIAL_SUCCESS`/`FAILURE`), Orchestrator State File (`AOP_STATE_{session_id}.json`) with atomic writes, crash recovery protocol (state file scan, PID liveness check, artifact detection, polling resume).
- **Task Dependency Management (C3)** — DAG declaration format with `depends_on`, `priority`, and `weight` fields. DAG execution engine with topological dispatch ordering. Dependency failure propagation (transitive SKIPPED marking).
- **DAG Cycle Detection + Deadlock Detection (C4)** — DFS-based cycle detection with three-color marking (WHITE/GRAY/BLACK) and cycle path reporting. Deadlock detection with 4-stage escalation: NORMAL → WARN → ESCALATE → DEADLOCK (stall counter across consecutive poll cycles).
- **Task Priority & Weight System (C5)** — Four priority levels (CRITICAL/HIGH/MEDIUM/LOW) with rank-based dispatch ordering. Numeric weight (1-5) for secondary sorting. Priority-adjusted timeouts (CRITICAL=2x, LOW=0.5x). Model tier suggestions per priority level.
- **Bounded Concurrency Queue (C6)** — Configurable `MAX_CONCURRENT` parameter limiting parallel executor count. Priority-ordered dispatch queue. Tuning guidance for different environments.
- **Multi-Executor Polling Loop** — Concurrent artifact monitoring with per-executor status tracking and per-executor timeout (kill only timed-out executor, others continue).
- **Event-Driven Detection** — Fast-polling at 3s interval for multi-executor. Optional Python (`watchdog`) and Node.js (`chokidar`) file watcher patterns for <1s detection latency.
- **Collision-safe Session ID** — 8-char hex, nanosecond-seeded (`date +%s%N | sha256sum | head -c 8`) with macOS fallback.
- **Task-ID namespaced artifacts** — `AOP_COMPLETE_{task_id}_{session_id}.json` naming convention prevents collisions in parallel dispatches.
- **Prompt 17** in AOP_WORKED_EXAMPLES.md — Parallel fan-out/fan-in with 3 executors (full end-to-end script).
- **Prompt 18** in AOP_WORKED_EXAMPLES.md — DAG execution with dependencies, priority dispatch, bounded concurrency, and deadlock detection.
- **Model Selection guide** — Mandatory pre-dispatch model selection with 3-tier system (Architect/Engineer/Operator) and cross-provider reference table.

### Changed
- **`task_id` promoted to REQUIRED** in completion artifact schema (was optional). Single-executor workflows may still omit it for backward compatibility.
- **`executor_id` added** as recommended optional field (`exec_{task_id}_{session_id}`).
- **Orchestration flow diagram** updated to show parallel executors, DAG-aware polling, and fan-in aggregation.
- **Pillar 4 (Active Vigilance)** updated with scaling guidance: standard polling for single-executor, fast-polling/event-driven for multi-executor.
- **Key Rules** expanded with multi-executor rules (per-executor timeouts, sweep-per-interval, intermediate progress reporting).
- **Status** changed from `Development (v4.0.0-beta)` to `Release Candidate (v4.0.0-rc.1)`.

### Fixed
- **Bash code quality:** Removed `local` keyword used outside functions in DAG execution loop (invalid in bash outside function scope).
- **Model reference inconsistency:** Fixed `gemini-2.0-flash` → `gemini-3-flash` in Cross-LLM Command Reference to match Model Selection table.

## [3.0.0] - 2026-03-17

### Changed
- **Unified protocol rewrite.** Merged V1 and V2 into a single operational protocol. No more V1/V2 split.
- **Agent-agnostic.** Removed all agent-specific names (Forge, Emma, Magneto). AOP now works with any orchestrator CLI.
- **Bash-primary.** All examples standardized on bash with PowerShell as documented alternative.
- **SKILL.md is the authoritative document.** README.md serves as entry point and summary.

### Added
- **Security Boundaries section** in SKILL.md — trusted workspaces, write_paths, bypass table, post-execution verification.
- **Error Recovery section** in SKILL.md — timeout kill, crash recovery, orphaned processes, rollback protocol.
- **Governance (Lightweight) section** in SKILL.md — JSONL audit trail, guard rails defaults, cost tracking.
- **Seven Pillars in 3-part format** — each pillar now has Definition + Implementation Command + Verification Test.
- **Completion Artifact Schema** formalized with required/optional fields and naming convention.
- **Cross-LLM Known Quirks** sub-section with platform-specific gotchas.

### Removed
- **v2/ directory** — Python implementation (Pydantic models, 141 tests, schemas) removed. Zero production usage. Concepts absorbed into SKILL.md protocol rules.
- **V1/V2 distinction** — single protocol, version-agnostic.
- **Agent-specific references** — all persona names removed from all documents.

## [2.1.0] - 2026-03-16

### Added
- **Claude Code execution patterns** in SKILL.md — dedicated section for `claude -p` with inline and file-based prompt options.
- **File-based prompt pattern** — write complex prompts to `.md` file, pipe via `cat file | claude -p`. Solves escaping issues with code snippets, tables, special characters.
- **Artifact-based completion signal** — Executor creates JSON completion file; Orchestrator polls for existence. Replaces stdout parsing.
- **Sub-agents vs Headless AOP distinction** — critical documentation clarifying that internal sub-agent tools (Agent tool, etc.) are NOT AOP headless sessions.
- **Prompt 15** in AOP_WORKED_EXAMPLES.md — Claude-to-Claude production AOP with file-based prompt and artifact polling.
- **Prompt 16** in AOP_WORKED_EXAMPLES.md — Headless documentation Executor pattern.
- **Production case study** `orchestrations/2026-03-16_docx-indexer-w1w2/` — first real production AOP execution (11 code findings, 8 files, 372/372 tests).
- **Lessons from Production** section in README.md — 5 key learnings from real execution.

### Changed
- Status upgraded from `Production-Ready` to `Production-Validated` (proven in real codebase with real tests).
- README.md version updated to 2.1.0.
- AOP-EXECUTIVE-SUMMARY.md version updated to 2.1.0.

### Production Metrics (2026-03-16)
- Code Executor: 84 tool calls, ~9 min, 8 files, 2 commits, 0 regressions.
- Doc Executor: 20 tool calls, ~2 min, 3 files updated.
- Polling: 4 polls to detection (~2 min).
- All 7 Pillars applied and verified.

## [2.0.0] - 2026-03-01

### Added
- **AOP JSON V2 Contract** — Full JSON-native orchestration protocol with backward compatibility to V1.
- **Role-based architecture** — Orchestrator, Executor, Router, Governance roles are model-agnostic.
- **Core modules** (`v2/core/`):
  - `models.py` — Pydantic v2 models for TASK envelope and RESPONSE.
  - `orchestrator.py` — Orchestration engine with delegation graph, checkpointing, rollback.
  - `version_router.py` — V1/V2 version detection and routing with fallback.
  - `guard_rail_engine.py` — Guard rail enforcement (timeouts, budgets, safety policies).
  - `transformation_layer.py` — V2↔V1 bidirectional message transformation.
  - `exceptions.py` — Error taxonomy with E_* codes per contract.
  - `audit_logger.py` — Structured audit trail generation with atomic writes.
  - `repo_auditor.py` — Audit trail replay and compliance validation.
- **JSON Schemas** (`v2/schemas/`):
  - `task_envelope.schema.json`
  - `executor_response.schema.json`
  - `audit_record.schema.json`
- **Test suite**: 141 tests, 92% coverage across 8 test files.
- **Audit trail system**: Structured JSONL records for full session observability.
- **Repo-Auditor**: 5 validation checks (message compliance, budget, guard rails, roles, payload limits).

### Milestones
- M1 (BUILD): Core implementation — 33 tests ✅
- M2 (TEST): Full test coverage — 50 tests ✅
- M3 (VALIDATE): Schema enforcement — 76 tests ✅
- M4 (AUDIT): Audit operational — 141 tests ✅

## [1.3.0] - 2026-02-22

### Status
- Seven Pillars framework — production-ready.
- Text-based orchestration protocol (V1).
- File-based state handover.
- Polling-based monitoring.
- See `orchestrations/` for V1 execution logs.
