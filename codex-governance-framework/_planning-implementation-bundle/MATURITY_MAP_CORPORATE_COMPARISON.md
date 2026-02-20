# Maturity Map: Corporate Comparison

Date: 2026-02-20
Model: Level 1 to Level 5 maturity

## Level Model

- Level 1: Ad hoc and manual.
- Level 2: Repeatable but person-dependent.
- Level 3: Defined process with partial enforcement.
- Level 4: Measured and deterministic with governance controls.
- Level 5: Fully institutionalized with automated enterprise controls.

## Maturity Matrix

| Capability | Typical Small Team | Typical Corporate DevOps | Current State | Gap to Level 5 |
|---|---|---|---|---|
| Determinism | Script behavior can vary by operator | Standardized runbooks with partial automation | Level 4: deterministic ordering and fail-closed contracts | Add policy-as-code checks in centralized CI and mandatory signed verification |
| Release discipline | Manual version tags, inconsistent gates | Formal release calendar and change control | Level 4: SemVer, deterministic artifacts, release gate | Add remote protected release workflow and enforced approval gates |
| Artifact integrity | Artifacts exist but checks are optional | Checksums often required in regulated teams | Level 4: zip + manifest + SHA256SUMS required | Add immutable artifact registry and automated provenance attestations |
| Compatibility governance | Runtime breakages discovered late | Compatibility tested in pre-prod environments | Level 4: explicit bootstrap compatibility contract | Add compatibility matrix automation across multiple supported versions |
| Auditability | Logs exist but are inconsistent | Centralized logging with policy retention | Level 4: structured logs and explicit contract codes | Add centralized immutable audit storage and automated compliance reports |
| Multi-machine reproducibility | Machine drift is common | Provisioning standards reduce drift | Level 4: sync and onboard convergence model | Add fleet-level automated drift scheduling and policy enforcement |
| CI readiness | Local scripts, no formal gate | CI pipelines with quality gates | Level 3.5 to 4: local CI simulation contract defined | Implement pipeline hooks with required policy outcomes |
| Remote governance | Informal branch controls | Protected branches and PR policy | Level 2: deferred by design in current baseline | Implement branch protections, tag controls, and PR-required checks |

## Domain Comparison Summary

- Compared to a typical small team, current state is more deterministic and more explicit in failure contracts.
- Compared to a typical corporate DevOps team, current state is strong in local governance discipline but still pending centralized remote enforcement.

## Current Maturity Position

Overall maturity is Level 4 for local deterministic governance and release traceability.

## Path to Level 5

1. Integrate CI-ready checks into enforced pipeline gates.
2. Activate remote governance controls (protected branches, PR checks, tag permissions).
3. Add organization-level audit retention and compliance automation.
4. Automate cross-version compatibility matrix validation.
