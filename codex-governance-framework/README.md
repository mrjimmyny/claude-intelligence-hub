# Codex Governance Framework

## Purpose

`codex-governance-framework` is the institutional documentation bundle for deterministic governance of the codex bootstrap architecture.

It defines structure, operating boundaries, and controlled next steps without changing runtime behavior by itself.

## Baseline and Compatibility Reference

- Baseline governance version: `v1.0.0`
- HUB compatibility reference commit: `e138718`

These references define the validated baseline used by this bundle.

## Relationship to codex-skill-adapter

- `codex-skill-adapter` is the runtime and packaging execution surface.
- This framework provides the governance contracts and operator guidance used to control that execution surface.
- This bundle is documentation-governance, not runtime activation.

## Folder Map

- `planning/`
- Institutional analysis and governance boundary documents.

- `next-steps/`
- Deferred but contract-defined milestone documents (including the `v1.0.1` CI-ready contract).

- `playbook/`
- Operator-facing execution references, phase summaries, architecture principles, and passive skill definition.

## Recommended Reading Order

1. `playbook/ARCHITECTURE_OVERVIEW.md`
2. `playbook/GOVERNANCE_PRINCIPLES.md`
3. `planning/EXECUTIVE_SUMMARY_CURRENT_STATE.md`
4. `playbook/ROADMAP_CHRONOLOGICAL.md`
5. `playbook/PHASE_SUMMARIES.md`
6. `playbook/STEP_BY_STEP_IMPLEMENTATION_GUIDE.md`
7. `next-steps/CONTRACT_v1.0.1_CI_READY_SCRIPT.md`
8. `playbook/SKILL.md`

## Current Governance Status

- Phase 5 baseline is complete.
- Phase 5.1 is deferred by governance decision.
- Skill remains passive and not catalog-activated in this state.

## Next Milestone

- `v1.0.1`: CI-ready governance check script contract implementation (`run-full-governance-check.ps1`) with deterministic output markers and stable exit semantics.
