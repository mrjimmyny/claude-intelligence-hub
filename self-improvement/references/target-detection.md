# Target Detection

Determine the type of the target passed to `/self-improvement <target-path>`. Execute this procedure once at the start of Phase 1 (Setup) before loading any scoring dimensions or creating branches.

## Detection Table

| Priority | Type | Marker | Action |
|---|---|---|---|
| 1 | Skill | Directory contains `SKILL.md` | Load skill scoring dimensions |
| 2 | Project | Directory contains `PROJECT_CONTEXT.md` | Load project scoring dimensions |
| 3 | Script | File extension is `.sh`, `.ps1`, or `.py` | Load script scoring dimensions |
| 4 | Protocol | `.md` file whose parent (up to 2 levels) does NOT contain `SKILL.md` or `PROJECT_CONTEXT.md` | Load protocol scoring dimensions |
| 5 | Unknown | None of the above | STOP — ask operator |

First match wins. Do not continue evaluating lower-priority rules once a match is found.

## Detection Procedure

Follow these steps in order:

**Step 1 — Determine whether the target is a directory or a file.**

If the target path has no file extension and resolves to a directory on disk, treat it as a directory target. Otherwise treat it as a file target.

**Step 2 — Directory target.**

1. Check whether `SKILL.md` exists directly inside the target directory.
   - If yes → type is **Skill**.
2. Check whether `PROJECT_CONTEXT.md` exists directly inside the target directory.
   - If yes → type is **Project**.
3. Neither marker found → type is **Unknown**. STOP. See Unknown Handling below.

**Step 3 — File target.**

1. Check the file extension.
   - Extension is `.sh`, `.ps1`, or `.py` → type is **Script**. Stop evaluating.
2. Walk up the directory tree from the file's parent, up to 2 ancestor levels total (parent + grandparent).
   - If any of those directories contains `SKILL.md` → type is **Skill**. Stop evaluating.
   - If any of those directories contains `PROJECT_CONTEXT.md` → type is **Project**. Stop evaluating.
3. Extension is `.md` and no skill/project marker found in ancestors → type is **Protocol**.
4. None of the above → type is **Unknown**. STOP. See Unknown Handling below.

## Parent-Directory Resolution

When the target is a single file, the framework inspects the file's parent directory and up to two levels of ancestors for `SKILL.md` or `PROJECT_CONTEXT.md`.

A `.md` file inside a skill directory is detected as part of a Skill, not as a standalone Protocol. Only `.md` files outside any skill or project directory are classified as Protocol.

Example: `_skills/daily-doc-information/README.md` — the parent `daily-doc-information/` contains `SKILL.md`, so the type is Skill, not Protocol.

## Scope Resolution for File Targets

When the target is a single file (not a directory), apply the following scope rules:

- **Scope (Gate 6 boundary):** The target file itself. The framework may only modify the target file during the improvement run.
- **Branch naming:** Slugify the target path by replacing all path separators and removing the file extension, then append the run date. Example:
  - Input: `_skills/daily-doc-information/scripts/checkpoint-verify.sh`
  - Branch: `self-improvement/checkpoint-verify-2026-03-28`
- **Worktree:** Clone the entire repository (git requires a full working tree), but Gate 6 enforces that only the target file may be modified.

When the target is a directory, the scope is the entire directory tree.

## Output Format

Detection produces a structured result that the rest of the framework consumes. Populate all four fields before proceeding to Phase 2.

| Field | Description | Example |
|---|---|---|
| `type` | Detected type: `skill`, `project`, `script`, or `protocol` | `skill` |
| `scope_path` | Directory or file that defines the Gate 6 modification boundary | `_skills/daily-doc-information/` |
| `branch_slug` | Slugified name used for branch creation | `self-improvement/daily-doc-information-2026-03-28` |
| `key_files` | List of files to analyze in the target | `[SKILL.md, scripts/checkpoint-verify.sh, ...]` |

## Examples

### Skill (directory target)

Target: `_skills/daily-doc-information/`

- `SKILL.md` found directly inside → type = **skill**
- `scope_path` = `_skills/daily-doc-information/`
- `branch_slug` = `self-improvement/daily-doc-information-2026-03-28`
- `key_files` = all files under `_skills/daily-doc-information/`

### Project (directory target)

Target: `obsidian/CIH/projects/hr_kpis_board/`

- No `SKILL.md` found
- `PROJECT_CONTEXT.md` found directly inside → type = **project**
- `scope_path` = `obsidian/CIH/projects/hr_kpis_board/`
- `branch_slug` = `self-improvement/hr-kpis-board-2026-03-28`
- `key_files` = all files under `obsidian/CIH/projects/hr_kpis_board/`

### Script (file target)

Target: `_skills/daily-doc-information/scripts/checkpoint-verify.sh`

- Extension is `.sh` → type = **script**
- `scope_path` = `_skills/daily-doc-information/scripts/checkpoint-verify.sh`
- `branch_slug` = `self-improvement/checkpoint-verify-2026-03-28`
- `key_files` = `[checkpoint-verify.sh]`

### Protocol (file target, standalone .md)

Target: `claude-intelligence-hub/references/project-planning-methodology-guide-v1.0.md`

- Extension is `.md`
- Parent `references/` — no `SKILL.md` or `PROJECT_CONTEXT.md` found
- Grandparent `claude-intelligence-hub/` — no `SKILL.md` or `PROJECT_CONTEXT.md` found
- → type = **protocol**
- `scope_path` = `claude-intelligence-hub/references/project-planning-methodology-guide-v1.0.md`
- `branch_slug` = `self-improvement/project-planning-methodology-guide-v1.0-2026-03-28`
- `key_files` = `[project-planning-methodology-guide-v1.0.md]`

### Protocol (file target, .md inside a skill — NOT protocol)

Target: `_skills/daily-doc-information/README.md`

- Extension is `.md`
- Parent `daily-doc-information/` contains `SKILL.md` → type = **skill** (not Protocol)

## Unknown Handling

When no type can be determined, do NOT proceed. Execute the following:

1. Stop all subsequent phases immediately.
2. Report to the operator:
   - The target path that was evaluated
   - Which markers were checked and were not found
   - The directory levels that were inspected
3. Ask the operator to confirm one of the following:
   - Provide a corrected target path
   - Specify the type manually (one of: `skill`, `project`, `script`, `protocol`)
   - Cancel the run
4. Do not infer or guess the type. Only resume after the operator provides an explicit answer.

Example output for Unknown:

```
Target detection failed for: some/unknown/target/

Checks performed:
- SKILL.md: not found
- PROJECT_CONTEXT.md: not found
- File extension: not applicable (directory)
- Ancestor scan: not applicable (directory)

Cannot determine target type. Please confirm:
  (a) Provide a corrected target path
  (b) Specify type manually: skill | project | script | protocol
  (c) Cancel the run
```
