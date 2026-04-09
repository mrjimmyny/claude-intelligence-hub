# Repo Auditor Skill v2.2.0

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
- `PHASE 1.5`: deep cross-file validation (11 sub-validations)
- `PHASE 2`: spot-check sampling
- `PHASE 3`: closure and checkpoint consolidation
- `PHASE 3.6`: release tag and GitHub release publication

Checkpoint gates are strict: unresolved `CRITICAL ERROR` always results in `BLOCKED`.

## Phase 1.5 Cross-File Validations
The protocol enforces these eleven validations with explicit bash commands and objective criteria:
1. Skill count (`README` declaration vs actual repository count)
2. Version cross-check (`README` table vs skill `.metadata`)
3. Architecture completeness (`README` tree vs repository filesystem)
4. Reference accuracy (version references in documentation)
5. Orphan file detection (with documented exceptions)
6. Internal link validation (critical vs non-critical severity)
7. `CHANGELOG` completeness (target version has real entries)
8. `EXECUTIVE_SUMMARY` Component Versions completeness (by skill name, not just version number)
9. README Quick Commands per-skill validation (every skill present in the table)
10. `EXECUTIVE_SUMMARY` Key Achievements table validation (every skill in the table)
11. Stale metrics detection (file count, skill count, commit count in README prose)

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

## Artifact Map

| File | Role | Updated by |
|---|---|---|
| `SKILL.md` | Full deterministic protocol — every phase, checkpoint, validation, gate | Human or release PR |
| `README.md` | Surface-level index of the skill — purpose, modes, artifacts, quick start | Human or release PR |
| `.metadata` | Machine-readable version and routing metadata | Release automation |
| `AUDIT_TRAIL.md` | YAML-structured evidence log of every audit execution | Agent at audit time (append-only) |
| `scripts/validate-trail.sh` | Structural validator for `AUDIT_TRAIL.md` (runs independently) | Human or release PR |

`AUDIT_TRAIL.md` is **append-only during audits**: new executions add new records; old entries are immutable historical evidence and MUST NOT be edited retroactively.

## Quick Start

The fastest path from zero to a first audit on a target repository:

```bash
# 1. Confirm repo-auditor is installed as a skill in ~/.claude/skills/
ls ~/.claude/skills/repo-auditor/

# 2. cd into the target repository (must be a git repo with a clean tree)
cd /path/to/target-repo
git status --short

# 3. Trigger the skill with an explicit mode
/repo-auditor --mode AUDIT_ONLY

# 4. Inspect the evidence log produced in the target repo
cat AUDIT_TRAIL.md

# 5. Validate the trail structure
bash ~/.claude/skills/repo-auditor/scripts/validate-trail.sh AUDIT_TRAIL.md
```

For an audit that also applies trivial fixes and publishes a release:

```bash
/repo-auditor --mode AUDIT_AND_FIX
```

`AUDIT_AND_FIX` MUST be explicit — the default is `AUDIT_ONLY` for safety (v2.2.0).

## `.metadata` Fields — Required vs Optional

The `.metadata` file is JSON and drives version routing. Fields:

| Field | Required? | Purpose |
|---|---|---|
| `name` | **required** | Skill identifier; MUST match the directory name |
| `version` | **required** | Canonical version (source of truth — all other files must match) |
| `status` | **required** | One of `draft`, `production`, `deprecated`, `experimental` |
| `description` | **required** | One-line summary used by skill routers and catalogs |
| `auto_load` | optional | `true` to load the skill automatically; defaults to `false` |
| `priority` | optional | `low`, `normal`, `high`; routing hint for skill dispatchers |
| `command` | optional (but recommended) | Slash command; validated by Phase 1.2.5 if present |
| `aliases` | optional | Array of alternate slash commands |

A missing **required** field is a `CRITICAL ERROR` in Phase 1.2.3. A missing optional field is silent.

## Version Sync Guardrails

`repo-auditor` enforces version consistency in the target repo because version drift is the #1 source of audit noise. For the skill's own files, these must stay synchronized on every release:

| File | What to update |
|---|---|
| `repo-auditor/.metadata` | `version` field (source of truth) |
| `repo-auditor/SKILL.md` | `**Version:**` line near the top |
| `repo-auditor/README.md` | `# Repo Auditor Skill vX.Y.Z` on line 1 |
| `repo-auditor/AUDIT_TRAIL.md` | `# AUDIT_TRAIL - repo-auditor vX.Y.Z` header |
| Hub `CHANGELOG.md` | New `[hub-version]` entry referencing the skill bump |
| Hub `HUB_MAP.md` | Version reference next to the skill name |

The hub-level sync script handles most of these automatically:

```bash
bash /c/ai/claude-intelligence-hub/scripts/sync-versions.sh repo-auditor
```

After running it, also run the integrity check:

```bash
bash /c/ai/claude-intelligence-hub/scripts/integrity-check.sh
```

Must report `6 passed / 0 failed` before committing.

## Usage Note
When this skill is triggered, execute commands exactly as specified in `SKILL.md`, log evidence in `AUDIT_TRAIL.md`, and treat checkpoint gates as non-negotiable.
