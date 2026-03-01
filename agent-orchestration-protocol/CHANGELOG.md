# Changelog — Agent Orchestration Protocol

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
