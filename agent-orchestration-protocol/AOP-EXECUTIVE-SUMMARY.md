# Agent Orchestration Protocol (AOP): Executive Summary

Purpose: Provide structured input for NotebookLM to generate visual and dynamic artifacts (infographics, slide decks, mind maps, audio, video).

## Executive Snapshot

| Field | Value |
| --- | --- |
| Name | Agent Orchestration Protocol (AOP) |
| Version | 4.2.0 |
| Status | Production-Validated |
| Category | Multi-Agent Coordination |
| Command | `/aop` |
| Aliases | `/orchestrate`, `/delegate` |
| Maintained By | Claude Intelligence Hub |
| Last Updated | 2026-03-29 |
| Roadmap Version | 2.0 (Next Review: Q2 2026) |

---

## What AOP Is

AOP is a methodology and operating framework that allows a single **Orchestrator** to coordinate multiple **Executor agents** across complex, multi-step tasks. It turns isolated CLI agents into a coordinated system with standardized delegation, monitoring, validation, and recovery. AOP is agent-agnostic — it works with any CLI that supports headless execution (Claude Code, Codex, Gemini, or future tools).

---

## The Problem AOP Solves

Traditional single-agent workflows break down when tasks require multiple specialties, parallel execution, or long-running multi-phase coordination. AOP addresses:

- Multi-skill challenges that exceed a single agent's capabilities.
- Parallel workstreams that must be executed simultaneously.
- Review loops that require creator, reviewer, and finalizer roles.
- Long-running tasks that need monitoring and recovery.

---

## Operating Model

- **Orchestrator:** Delegates, monitors, and validates tasks using shell commands.
- **Executor agents:** Headless CLI processes that execute delegated tasks independently.
- **Headless Mode:** Executors run non-interactively as separate OS processes for full automation.
- **Trusted Workspace:** Pre-approved directories where permission bypass is allowed.

AOP is NOT the internal sub-agent tool pattern. A real AOP execution always spawns an independent OS process via `claude -p`, `codex exec`, or `gemini -p`.

---

## The Seven Pillars of AOP

1. **Environment Isolation:** Executors run as independent OS processes with clean, isolated context — no shared state with the Orchestrator.
2. **Absolute Referencing:** Mandatory absolute paths eliminate ambiguity when working directories differ between Orchestrator and Executor.
3. **Permission Bypass:** Automation bypass flags are used only inside pre-approved trusted workspaces.
4. **Active Vigilance (Polling):** Orchestrator monitors task completion by polling for a JSON completion artifact — never waits synchronously.
5. **Integrity Verification:** Orchestrator independently verifies outputs by checking actual files and running tests — not by trusting the artifact alone.
6. **Closeout Protocol:** Every task ends with an explicit `SUCCESS` or `FAIL` status and concrete evidence.
7. **Constraint Adaptation:** If the Orchestrator cannot access a resource directly, it delegates the operation to a properly scoped executor.

---

## Execution Standard

### Primary Pattern: File-Based Prompt (Recommended)

```bash
# bash (primary)
cat AOP_PROMPT_${SESSION_ID}.md | claude -p --dangerously-skip-permissions --model claude-sonnet-4-6 &
EXECUTOR_PID=$!
```

```powershell
# PowerShell (alternative)
Get-Content "AOP_PROMPT_${SESSION_ID}.md" | claude -p --dangerously-skip-permissions --model claude-sonnet-4-6
```

File-based prompts are the production default — they avoid all escaping issues with code blocks, JSON, and special characters.

### Supported CLIs

| Task | Claude Code | Codex | Gemini |
| :--- | :--- | :--- | :--- |
| Headless execution | `claude -p "..."` | `codex exec "..."` | `gemini -p "..."` |
| Bypass flag | `--dangerously-skip-permissions` | `--dangerously-bypass-approvals-and-sandbox` | `--approval-mode yolo` |
| Default model | `claude-sonnet-4-6` | `gpt-5.2-codex` (official DEFAULT) | `gemini-2.5-flash` |

---

## Security Boundaries

- **Trusted workspaces** are pre-approved directories where bypass flags are permitted (e.g., `C:\ai\`, `C:\ai\_worktrees\`).
- **`write_paths` declaration** is mandatory in every executor prompt — defines exactly what the executor may write.
- **Post-execution verification:** Orchestrator runs `git diff --name-only` and compares against the declared write scope.
- **Bypass flags** skip interactive prompts only — they do not expand OS-level permissions or grant new capabilities.
- **Never use bypass** for system directories, credential stores, or paths outside the trusted allow-list.

---

## Reliability and Recovery

- **Active Vigilance:** Artifact-based polling loop verifies task completion (non-empty JSON file).
- **Integrity Verification:** Orchestrator checks actual file outputs, not just the artifact status field.
- **Timeout Kill:** After 20 polls (~14 min), the Orchestrator kills the executor PID and escalates.
- **Crash Recovery:** Orchestrator checks for error artifacts and git state to decide retry or abort.
- **Rollback Protocol:** `git revert` for committed bad content; `git checkout -- .` for uncommitted changes.
- **Closeout Protocol:** Orchestrator always provides final `SUCCESS` or `FAIL` status with evidence.

---

## Production Capabilities (v3.0.0) + Multi-Executor Orchestration (v4.0.0-rc.1)

- Seven-Pillar Framework fully implemented and production-validated.
- Unified protocol — no V1/V2 split. Single operating standard.
- File-based prompt pattern for complex executor instructions.
- Artifact-based completion signal for reliable polling.
- Claude-to-Claude orchestration (Opus Orchestrator + Sonnet Executor).
- Cross-LLM orchestration (Claude Code, Codex, Gemini).
- Documentation delegation (executors update structured docs).
- Constraint adaptation and delegation.
- Security boundaries with trusted workspaces and write_paths declarations.
- Lightweight governance: JSONL audit trail, guard rails, cost tracking.
- Error recovery: timeout kill, crash recovery, orphaned process detection, rollback.
- Completion artifact schema with required/optional fields.
- Production-validated prompt cookbook (18 patterns in AOP_WORKED_EXAMPLES.md).
- **Pre-Review Integrity Gate** — mandatory artifact validation at all tiers before grading.
- **Python-Based Artifact Generation** — mandatory for Codex to prevent malformed JSON.
- **Autoresearch Patterns** — Git-as-Memory, Experiment Commit Convention, Guard Pattern.
- **Multi-Executor Coordination** — parallel dispatch with disjoint write path validation and per-executor isolation.
- **Fan-In/Fan-Out Orchestration** — fan-out N executors, fan-in results into aggregation artifact with partial success handling.
- **Task Dependency Management (DAG)** — dependency declaration, topological dispatch, cycle detection, failure propagation.
- **Deadlock Detection** — 4-stage escalation monitoring stalled workflows across consecutive poll cycles.
- **Task Priority & Weight System** — CRITICAL/HIGH/MEDIUM/LOW with weight-based sorting, priority-adjusted timeouts, model tier suggestions.
- **Bounded Concurrency Queue** — configurable MAX_CONCURRENT with priority-ordered dispatch.
- **Crash Recovery** — Orchestrator State File enables resumption after crash with PID liveness checking.

---

## Production Use Cases

- Document engineering and multi-stage review pipelines.
- Code review workflows with creator → reviewer → finalizer chains.
- Research synthesis across multiple sources.
- Quality assurance validation across agent outputs.
- Multi-file code refactoring with test verification.

---

## Supported CLIs

AOP is agent-agnostic and works with any CLI that supports headless execution:

- **Claude Code** — `claude -p`, file-based prompts via pipe, `--dangerously-skip-permissions`
- **Codex** — `codex exec`, `--dangerously-bypass-approvals-and-sandbox`
- **Gemini** — `gemini -p`, `--approval-mode yolo`
- **Future CLIs** — any tool that accepts stdin instructions and runs as an independent process

---

## Proof Points

- Chain delegation case study (2026-02-25): multi-level delegation with cross-LLM orchestration, 100% success rate.
- Production code execution (2026-03-16): Opus 4.6 Orchestrator launched Sonnet 4.6 headless to implement 11 findings across 8 files in docx-indexer. 372/372 tests maintained. Two headless sessions (code + docs) both SUCCESS.
- Current metrics: 100% success rate on all production executions; under 10 minutes average completion for standard workflows; artifact-based polling detects completion in 2-4 polls.

---

## Roadmap

- **Phase 1: Enhanced Monitoring (Q2 2026)** — Event-driven orchestration, WebSocket status, live dashboards, sub-5s response time.
- **Phase 2: Agent Mesh Network (Q3 2026)** — Peer-to-peer agent messaging, async task queues, dynamic discovery.
- **Phase 3: Advanced Security and Compliance (Q4 2026)** — Signed delegations, audit logs, RBAC, containerized sandboxes.
- **Phase 4: AI-Driven Orchestration (Q1 2027)** — Auto agent selection, predictive timeouts, failure pattern recognition.

---

## Pillar Evolution

| Pillar | Current (v4.0.0-rc.1) | Future |
| --- | --- | --- |
| Environment Isolation | Independent OS processes, headless CLI, multi-executor parallel dispatch | Containerized environments with resource limits |
| Absolute Referencing | Mandatory absolute paths | Virtual file system abstraction |
| Permission Bypass | Flag-based trusted workspace bypass | Token-based, expiring authorization |
| Active Vigilance | Adaptive polling + fast-polling (3s) + optional file watcher (<1s) | Event-driven notifications (under 5s) |
| Integrity Verification | File existence, size, git diff checks | Content-aware, AI-based quality scoring |
| Closeout Protocol | Structured JSON artifact + text status | Fully structured JSON reports with metrics |
| Constraint Adaptation | Delegated verification when sandboxed | Proactive capability detection |

---

## Key Assets

- `SKILL.md` — authoritative operational reference. Seven Pillars in 3-part format. Full command reference.
- `README.md` — entry point and summary. Quick start, pillar overview, cross-LLM table.
- `AOP_WORKED_EXAMPLES.md` — production-validated prompt templates (16+ patterns).
- `orchestrations/` — real-world execution reports, metrics, and lessons learned.
- `CHANGELOG.md` — full version history.

---

## Suggested Visuals for NotebookLM

- Orchestrator → Executor flow diagram (delegation, polling, verification, closeout).
- Seven Pillars wheel or stacked diagram with definition + command + verification.
- Cross-LLM support matrix (Claude Code, Codex, Gemini).
- Roadmap timeline (Q2 2026 to Q1 2027).
- Metrics cards (success rate, average completion, polling intervals).
- Security routing decision flow (trusted vs untrusted workspaces).

---

**Version:** 4.2.0 | **Status:** Production-Validated | **Last Updated:** 2026-03-29
