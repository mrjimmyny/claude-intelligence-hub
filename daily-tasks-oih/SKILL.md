---
name: daily-tasks-oih
description: Daily task orchestration for Obsidian Intelligence Hub (OIH). Use when the user wants to capture tasks in a pool, dispatch tasks to per-agent daily files, execute tasks with status/evidence tracking, and maintain conflict-safe daily operations with strict English documentation.
command: /daily-tasks-oih
aliases: [/dtoih, /daily-tasks]
---

# Daily Tasks OIH
**Version:** 1.0.0

## Objective
Run a deterministic workflow for daily task planning and execution in OIH:
- Capture tasks quickly in `Daily Tasks Pool.md`
- Dispatch tasks into per-agent daily files
- Track execution with status and evidence
- Prevent file write conflicts

## Non-Negotiable Rules

1. Keep all operational documentation in English.
2. Use one daily file per `executed_date + agent`.
3. Preserve original task intent when rewriting or structuring records.
4. Never duplicate tasks with the same `task_id` in a target daily file.

## Required Paths

- Pool: `CIH/daily-tasks/Daily Tasks Pool.md`
- Index: `CIH/daily-tasks/Daily Tasks Agents.md`
- Template: `CIH/daily-tasks/Daily Tasks Template.md`
- Blueprint: `CIH/daily-tasks/Daily Tasks Blueprint.md`

## File Naming Contract

Daily execution file name must be:

`Daily Tasks Agents - YYYY-MM-DD - <agent>.md`

Example:

`Daily Tasks Agents - 2026-03-05 - codex.md`

## Frontmatter Contract (daily execution files)

- `created_at`
- `executed_date`
- `agent_id`

## Workflow Modes

### Mode 1: Capture

Use when user is dumping ideas quickly.

Actions:
1. Append entries to `Daily Tasks Pool.md`.
2. Keep minimal routing fields: `task_id`, `agent`, `executed_date`, `status`.
3. Do not over-structure unless requested.

### Mode 2: Dispatch

Use when user asks to prepare daily execution files from pool.

Actions:
1. Read pool tasks.
2. Filter by `agent` and `executed_date`.
3. For each group:
   - Create daily file from template if missing.
   - Append tasks if file exists.
4. Enforce idempotency:
   - If `task_id` already exists in target file, update status/details instead of duplicating.

### Mode 3: Execute

Use when user asks to execute tasks assigned to one agent.

Actions:
1. Open the corresponding daily file.
2. Execute tasks in dependency order.
3. Update:
   - dashboard status
   - detailed task record
   - evidence
   - change history

### Mode 4: Close

Use at end of day.

Actions:
1. Confirm each completed task has evidence.
2. Mark remaining tasks as `blocked`, `deferred`, or keep in pool.
3. Prepare next-day entries in pool as needed.

## Conflict-Safe Writing Policy

1. Agent writes only in its own daily file.
2. Shared updates go to pool/index only.
3. If concurrent edits are detected:
   - re-read file
   - merge safely
   - avoid destructive overwrite

## Encoding Policy

1. Prefer UTF-8 without BOM.
2. Keep content ASCII-safe when possible.
3. Replace malformed characters immediately when detected.

## References

Read only when needed:

- Examples:
  - `references/examples/pool-example.md`
  - `references/examples/daily-file-example-codex.md`
- Templates:
  - `references/templates/daily-tasks-pool-template.md`
  - `references/templates/daily-tasks-index-template.md`
  - `references/templates/daily-tasks-agent-template.md`

## Validation Checklist

- Daily files follow naming contract.
- `created_at`, `executed_date`, and `agent_id` exist.
- No duplicate `task_id` in target daily file.
- Status and evidence are up to date.
- All operational text remains in English.

## Quick Command Examples

```bash
/daily-tasks-oih --mode capture --file "CIH/daily-tasks/Daily Tasks Pool.md"
/daily-tasks-oih --mode dispatch --agent codex --date 2026-03-05
/daily-tasks-oih --mode execute --agent codex --date 2026-03-05
/daily-tasks-oih --mode close --date 2026-03-05
```
