# Architecture Overview

## Goal

Provide a deterministic governance architecture for multi-agent bootstrap operations with explicit contracts.

## High-Level Components

- HUB (`claude-intelligence-hub`): canonical governance and catalog authority.
- Adapter (`codex-skill-adapter`): bootstrap execution and release packaging.
- Validation harness (`codex-multiagent-bootstrap`): regression and evidence generation.

## Canonical Contract Files

- `core_catalog/core_catalog.json`
- `core_catalog/bootstrap_compat.json`

## Runtime and Governance Flow

```text
+------------------------------+
| Canonical HUB Contracts      |
| core_catalog + bootstrap_compat |
+--------------+---------------+
               |
               v
+------------------------------+
| Bootstrap Runtime            |
| on/off/sync/audit/onboard    |
| explicit contract codes      |
+--------------+---------------+
               |
               v
+------------------------------+
| Structured Execution Logs    |
| project EXECUTION_LOGS/*.json|
+--------------+---------------+
               |
               v
+------------------------------+
| Regression Harness           |
| Phase4 + Phase5 checks       |
| FAIL_COUNT gates             |
+--------------+---------------+
               |
               v
+------------------------------+
| Release Governance           |
| SemVer, artifacts, hashes,   |
| tagging after gates          |
+------------------------------+
```

## Compatibility Governance Flow

```text
Load catalog version -> Load bootstrap compatibility range -> Compare against BOOTSTRAP_VERSION

If mode in {on,sync,audit,onboard} and out-of-range:
  Abort with ABORTED_BOOTSTRAP_VERSION_OUT_OF_RANGE
If mode == off:
  Bypass compatibility check to allow safe deprovision
```

## Boundary Model

- Documentation bundle defines process and contracts.
- Activation of skills into global catalog is a separate governance event.
- Remote governance controls are separate from local baseline institutionalization.

## Vocabulary Reference

- Contract code: explicit machine-readable execution outcome.
- Compatibility range: allowed bootstrap versions for current catalog state.
- Governance gate: measurable release acceptance condition.
- Deterministic marker: expected stable output string or structured field.
