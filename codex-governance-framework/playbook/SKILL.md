---
name: codex-governance-orchestrator
description: Deterministic documentation orchestrator for codex governance framework packaging, auditing, and extension planning.
---

# Codex Governance Orchestrator

## Purpose

Provide a deterministic operator workflow for governance
documentation packaging and governance-audit reporting.

## Trigger Phrases

Trigger this skill when requests include phrases such as:

- "build governance framework docs"
- "institutionalize codex governance"
- "create governance playbook"
- "audit governance bundle"
- "prepare CI-ready governance contract"
- "summarize maturity model"

## Passive Status in This Phase

This skill is passive documentation-orchestrator in the current phase.

- It is defined in this playbook folder.
- It is not added to `core_catalog/core_catalog.json` in this phase.
- It does not change global provisioning behavior by itself.

## Operator Authority Model

Strict authority boundaries:

1. Skill does not modify catalog.
2. Skill does not activate itself.
3. Skill does not bump versions.
4. Skill does not create releases.
5. Skill never mutates system without explicit approval.

## What This Skill Will Not Do

- Will not perform runtime refactors automatically.
- Will not alter bootstrap mode behavior.
- Will not perform remote governance setup.
- Will not modify root hub docs unless explicitly approved in mission scope.

## Safe Mode Guidance

Default to documentation-only mode.

Before any mutation action:

1. Confirm approved scope.
2. Present deterministic plan.
3. Wait for explicit approval.
4. Execute only approved steps.

## Bundle Paths (Relative)

- `./README.md`
- `./ROADMAP_CHRONOLOGICAL.md`
- `./PHASE_SUMMARIES.md`
- `./STEP_BY_STEP_IMPLEMENTATION_GUIDE.md`
- `./GOVERNANCE_PRINCIPLES.md`
- `./ARCHITECTURE_OVERVIEW.md`
- `../planning/EXECUTIVE_SUMMARY_CURRENT_STATE.md`
- `../planning/MATURITY_MAP_CORPORATE_COMPARISON.md`
- `../planning/IMPLEMENTATION_SCOPE_BOUNDARIES.md`
- `../next-steps/CONTRACT_v1.0.1_CI_READY_SCRIPT.md`

## Guided Reimplementation Flow

1. Load architecture and principles first.
2. Build phase roadmap and summaries.
3. Build deterministic step-by-step guide with verification snapshots.
4. Validate scope boundaries and deferred items.
5. Produce final institutional summary and maturity matrix.

## Audit Flow

1. Verify required file presence and exact paths.
2. Verify deterministic language and measurable gates.
3. Verify explicit boundaries and non-goals.
4. Verify no hidden assumptions.
5. Verify scope compliance before commit.

## Extension Roadmap Guidance

When extending this bundle:

1. Propose extension in a separate scoped mission.
2. Separate documentation expansion from runtime activation changes.
3. If catalog activation is requested, require dedicated governance review and regression gate.
4. Keep deterministic output markers and measurable acceptance criteria.
