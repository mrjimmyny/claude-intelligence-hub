# Implementation Scope Boundaries

Date: 2026-02-20

## Purpose

This document prevents future confusion by stating what this governance bundle intentionally does not change.

## Intentionally Not Done

1. Root hub docs were not modified.
2. `codex-governance-orchestrator` was not added to `core_catalog/core_catalog.json`.
3. Remote governance setup was not configured.
4. Runtime mode behavior was not expanded.

## Why Root Docs Were Not Modified

- Scope was intentionally constrained to create a self-contained and portable bundle.
- This avoids broad repository noise and keeps review boundaries clear.

## Why Skill Was Not Added to core_catalog

- Catalog updates change global provisioning behavior.
- Global activation requires separate governed review and regression cycle.
- This mission focuses on documentation institutionalization, not rollout activation.

## Why Remote Governance Is Deferred

- Remote controls need explicit policy decisions first:
  - repository destination
  - branch protection model
  - PR and tag authority model
- Deferring this avoids accidental governance drift.

## Boundary Rule

Any future change outside `codex-governance-framework/` must be approved as a separate scoped mission.
