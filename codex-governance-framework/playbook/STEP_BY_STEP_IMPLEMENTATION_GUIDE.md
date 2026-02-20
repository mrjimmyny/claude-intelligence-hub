# Step-by-Step Implementation Guide

## Purpose

Enable full reimplementation from scratch on a clean machine, with deterministic checkpoints after each phase.

## Preconditions Checklist

- Access to `C:/ai/claude-intelligence-hub`.
- Access to `C:/ai/codex-skill-adapter`.
- PowerShell available.
- Permission to create directory junctions.
- Git installed.

## Environment Assumptions

- Windows path semantics.
- User home path available at `$env:USERPROFILE`.
- No hidden modifications outside declared scope.

## Expected Top-Level Folder Structure

- `C:/ai/claude-intelligence-hub/`
- `C:/ai/codex-skill-adapter/`
- Working validation project path for test harness execution.

## Logging Locations

- Runtime mode logs: `<project>/EXECUTION_LOGS/*.json`
- Phase 4 test outputs: `<workspace>/EXECUTION_LOGS/phase4_test_results_*.json`
- Phase 5 test outputs: `<workspace>/EXECUTION_LOGS/phase5_test_results_*.json`

## Phase 0 Reimplementation

### Steps

1. Validate SKILL metadata contract formatting for core skills.
2. Normalize frontmatter and encoding behavior.
3. Confirm deterministic skill loader behavior.

### Deterministic Verification Snapshot

- Expected git state: only Phase 0 intended file deltas are present before commit.
- Expected directory structure: core skill directories include valid `SKILL.md`.
- Expected log markers: `PHASE0_SKILL_CONTRACT=PASS`.
- Expected FAIL_COUNT value: `0` when regression gate is executed.

## Route A Reimplementation

### Steps

1. Remove duplicate authority mapping paths.
2. Point authority mapping to HUB canonical source.
3. Validate no hub-root exposure from project scope.

### Deterministic Verification Snapshot

- Expected git state: only Route A intended deltas before commit.
- Expected directory structure: canonical authority path resolves to HUB.
- Expected log markers: `ROUTEA_AUTHORITY_CENTRALIZED=PASS`.
- Expected FAIL_COUNT value: `0` when regression gate is executed.

## Phase 1 Reimplementation

### Steps

1. Create and validate `core_catalog.json` contract.
2. Enforce schema and semver checks.
3. Enforce path safety and uniqueness.

### Deterministic Verification Snapshot

- Expected git state: catalog and validator deltas only.
- Expected directory structure: `core_catalog/core_catalog.json` exists and is canonical.
- Expected log markers: `PHASE1_CATALOG_AUTHORITY=PASS`.
- Expected FAIL_COUNT value: `0`.

## Phase 2 Reimplementation

### Steps

1. Implement `sync` mode.
2. Implement drift classification buckets.
3. Implement safe-by-default reconciliation and optional purge flow.

### Deterministic Verification Snapshot

- Expected git state: sync-specific implementation and test deltas only.
- Expected directory structure: global skill junction state converges after sync.
- Expected log markers: `core_sync.summary` present and valid.
- Expected FAIL_COUNT value: `0`.

## Phase 3 Reimplementation

### Steps

1. Implement `audit` mode as read-only.
2. Emit structured findings and summary contract codes.
3. Prove zero mutation under drift detection.

### Deterministic Verification Snapshot

- Expected git state: audit-specific implementation and test deltas only.
- Expected directory structure: no mutation side effects after audit runs.
- Expected log markers: `core_audit.summary.result` and `core_audit.summary.contract_code`.
- Expected FAIL_COUNT value: `0`.

## Phase 4 Reimplementation

### Steps

1. Implement `onboard` orchestration (`audit-before`, optional `sync`, `audit-after`).
2. Enforce purge lockout in onboarding context.
3. Emit consolidated onboarding report object.

### Deterministic Verification Snapshot

- Expected git state: onboarding-specific implementation and test deltas only.
- Expected directory structure: converged canonical junction state after onboarding.
- Expected log markers:
  - `onboarding.summary.before_status`
  - `onboarding.summary.after_status`
  - `onboarding.summary.contract_code`
- Expected FAIL_COUNT value: `0`.

## Phase 5 Reimplementation

### Steps

1. Add `$BOOTSTRAP_VERSION` and SemVer governance.
2. Add compatibility contract validation against canonical HUB compatibility file.
3. Add deterministic artifact packaging with hash outputs.
4. Add governed release playbook.

### Deterministic Verification Snapshot

- Expected git state: version governance and release tooling deltas only.
- Expected directory structure:
  - `core_catalog/bootstrap_compat.json`
  - `releases/vX.Y.Z/` artifact bundle
- Expected log markers:
  - `version_contract.result`
  - `ABORTED_BOOTSTRAP_VERSION_OUT_OF_RANGE` on forced mismatch tests
  - artifact verification PASS markers
- Expected FAIL_COUNT value: `0`.

## Final Global Verification

1. Phase 4 regression run returns `FAIL_COUNT=0` and `MISSING_LOGS=0`.
2. Phase 5 regression run returns `FAIL_COUNT=0`.
3. Artifact verification succeeds against manifest and checksums.
4. Git tree is clean after final commit.
