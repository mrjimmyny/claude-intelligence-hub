# Daily Tasks OIH (v1.0.0)

Daily workflow skill for task planning and execution in Obsidian Intelligence Hub.

## Purpose

`daily-tasks-oih` standardizes:
- fast task capture in a pool
- dispatch to per-agent daily files
- execution tracking with status/evidence
- close-of-day hygiene

## Slash Command

- Primary: `/daily-tasks-oih`
- Aliases: `/dtoih`, `/daily-tasks`

## Core Contracts

1. Language: operational docs and templates must be in English.
2. Daily file naming:
   - `Daily Tasks Agents - YYYY-MM-DD - <agent>.md`
3. Required frontmatter:
   - `created_at`, `executed_date`, `agent_id`
4. Idempotency:
   - never duplicate `task_id` in the same daily file.

## OIH Paths

- `CIH/daily-tasks/Daily Tasks Pool.md`
- `CIH/daily-tasks/Daily Tasks Agents.md`
- `CIH/daily-tasks/Daily Tasks Template.md`
- `CIH/daily-tasks/Daily Tasks Blueprint.md`

## Reference Material

### Examples

- `references/examples/pool-example.md`
- `references/examples/daily-file-example-codex.md`

### Templates

- `references/templates/daily-tasks-pool-template.md`
- `references/templates/daily-tasks-index-template.md`
- `references/templates/daily-tasks-agent-template.md`

## Typical Flows

### Capture

```text
Read Daily Tasks Pool.md and append new tasks with:
task_id, agent, executed_date, status, short title, optional steps.
```

### Dispatch

```text
Read pool, filter by agent/date, create missing daily file from template,
append non-duplicated tasks, keep reverse chronological order.
```

### Execute

```text
Open daily file for agent/date, execute tasks in dependency order,
update status and evidence after each task.
```

### Close

```text
Update change history, verify all done tasks have evidence,
carry unfinished tasks to pool.
```

## Safety Notes

- One writer per daily file (per agent).
- Re-read file before write if concurrent activity is suspected.
- Do not remove original request context from task records.
