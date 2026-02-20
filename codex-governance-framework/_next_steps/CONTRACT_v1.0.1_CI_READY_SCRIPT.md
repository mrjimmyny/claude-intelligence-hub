# Contract v1.0.1: CI-Ready Governance Check Script

Date: 2026-02-20
Target Version: v1.0.1

## 1. Purpose

Define a deterministic, idempotent, local CI simulation contract for governance validation without changing runtime behavior.

## 2. Scope

- Define one orchestration script contract.
- Define required checks, outputs, and exit behavior.
- Define measurable acceptance criteria for v1.0.1.

## 3. Non-Goals

- No change to runtime behavior of existing modes: `on`, `off`, `sync`, `audit`, `onboard`.
- No remote CI pipeline implementation in this version.
- No catalog schema change.
- No release governance policy expansion beyond orchestration check surface.

## 4. CI-Ready Definition

In this phase, CI-ready means:

- The full governance check can run locally in one command.
- The command emits deterministic machine-readable summary markers.
- Exit codes are stable and automation-compatible.
- The same command can be attached later to pipeline hooks with no contract changes.

## 5. Script Specification

### 5.1 Name and Location

- Script name: `run-full-governance-check.ps1`
- Expected location: `scripts/run-full-governance-check.ps1`

### 5.2 Script Responsibilities

The script must orchestrate:

1. Phase 4 regression check.
2. Phase 5 regression check.
3. Artifact verification check.
4. Contract summary output.

### 5.3 Required Exit Codes

- `0`: full success.
- Non-zero: any failed check.

### 5.4 Deterministic Output Markers

Required terminal markers:

- `GOV_CHECK_PHASE4=PASS|FAIL`
- `GOV_CHECK_PHASE5=PASS|FAIL`
- `GOV_CHECK_ARTIFACTS=PASS|FAIL`
- `GOV_CHECK_OVERALL=PASS|FAIL`
- `GOV_CHECK_EXIT_CODE=<n>`

## 6. Idempotency and Safety Requirements

The script must be idempotent and non-mutating:

1. Must not mutate runtime state.
2. Must not bump or modify version numbers.
3. Must not modify existing release artifacts.
4. Must be safe to run multiple times with identical logical results.
5. Must only read and validate artifacts unless explicitly run in a separate build mode (out of scope for this contract).

## 7. Version Bump Rules

- PATCH (`X.Y.Z+1`) when change is orchestration-only and does not expand validation surface.
- MINOR (`X.Y+1.0`) when a new validation surface is introduced.
- MAJOR is out of scope for this contract.

## 8. Regression Gate Requirements

Release is blocked unless:

- Phase 4 result: `FAIL_COUNT=0`
- Phase 5 result: `FAIL_COUNT=0`
- Governance check markers indicate overall PASS.

## 9. Artifact Verification Rules

Artifact verification success is true only when all are true:

1. Required files exist:
   - `codex-bootstrap-vX.Y.Z.zip`
   - `manifest.json`
   - `SHA256SUMS.txt`
2. `manifest.json` contains required keys:
   - `bootstrap_version`
   - `catalog_version`
   - `compatibility.min_bootstrap_version`
   - `compatibility.max_bootstrap_version`
   - `artifact.name`
   - `artifact.sha256`
   - `artifact.created_utc`
   - `build.git_commit`
   - `build.git_tag`
3. Hash values in `SHA256SUMS.txt` match actual file hashes.

## 10. Rollback Policy

On governance check failure:

1. Do not tag release.
2. Do not publish artifacts.
3. Keep current baseline unchanged.
4. Fix failing check.
5. Re-run full governance check until all markers PASS.

## 11. Measurable Acceptance Criteria

v1.0.1 is accepted only if all criteria pass:

1. `scripts/run-full-governance-check.ps1` exists.
2. Script exits with `0` on success and non-zero on failure.
3. Script prints all required deterministic markers.
4. Script demonstrates idempotent behavior across repeated runs.
5. Script does not modify runtime modes.
6. Phase 4 and Phase 5 checks both report `FAIL_COUNT=0` in release candidate validation run.
7. Artifact verification rules pass.
8. Governance summary marker reports `GOV_CHECK_OVERALL=PASS`.
