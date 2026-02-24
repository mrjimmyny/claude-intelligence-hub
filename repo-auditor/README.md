# Repo Auditor Skill v2.0.0

## Purpose
`repo-auditor` is a deterministic audit skill for repository governance quality.
It enforces deep validation across:
- Content correctness
- Cross-file consistency
- Repository completeness
- Release publication integrity

The protocol uses strict gate logic and can block progression whenever a critical condition fails.

## Core Principle
`Rigor without rigidity`
- Block when correctness is at risk.
- Warn when divergence is non-critical.
- Recover automatically only for trivial and safe fixes.

## Execution Modes
| Mode | Behavior | Modifies files | Publishes release |
|---|---|---|---|
| `AUDIT_AND_FIX` | Run full audit and auto-fix trivial issues | Yes | Yes |
| `AUDIT_ONLY` | Audit and report only | No | No |
| `DRY_RUN` | Simulate all checks and log intended actions | No | No |

Default mode is `AUDIT_AND_FIX`.

## Protocol Coverage
The skill implements all mandatory phases and checkpoints:
- `PHASE 0`: scope and preconditions
- `PHASE 1`: inventory and file fingerprints
- `PHASE 1.2`: structural validation
- `PHASE 1.5`: deep cross-file validation (7 sub-validations)
- `PHASE 2`: spot-check sampling
- `PHASE 3`: closure and checkpoint consolidation
- `PHASE 3.6`: release tag and GitHub release publication

Checkpoint gates are strict: unresolved `CRITICAL ERROR` always results in `BLOCKED`.

## Phase 1.5 Cross-File Validations
The protocol enforces these seven validations with explicit bash commands and objective criteria:
1. Skill count (`README` declaration vs actual repository count)
2. Version cross-check (`README` table vs skill `.metadata`)
3. Architecture completeness (`README` tree vs repository filesystem)
4. Reference accuracy (version references in documentation)
5. Orphan file detection (with documented exceptions)
6. Internal link validation (critical vs non-critical severity)
7. `CHANGELOG` completeness (target version has real entries)

## Required Artifacts
This skill includes these v2.0.0 artifacts:
- `SKILL.md`: full deterministic protocol
- `.metadata`: mandatory 4-field metadata
- `AUDIT_TRAIL.md`: YAML-based traceability template
- `scripts/validate-trail.sh`: trail structural validator

## Severity Model
`CRITICAL ERROR`
- Blocks progression immediately
- Requires recovery protocol before next phase

`WARNING`
- Does not block progression
- Must be logged in `AUDIT_TRAIL.md`
- Must appear in final report

## Recovery and Resume
When the audit is `BLOCKED`, the skill applies a deterministic recovery protocol:
- Auto-fix only trivial and safe issues
- Re-fingerprint and re-validate corrected files
- Revert and report if a new error appears

For interrupted audits, resume starts from the next incomplete phase using the latest saved checkpoint.

## Absolute Prohibitions
The skill enforces `P01` to `P13` in `SKILL.md`, including:
- No silent assumptions
- No checkpoint bypass
- No release without tag verification
- No unresolved `BLOCKED` state progression
- No vague criteria

## Usage Note
When this skill is triggered, execute commands exactly as specified in `SKILL.md`, log evidence in `AUDIT_TRAIL.md`, and treat checkpoint gates as non-negotiable.
