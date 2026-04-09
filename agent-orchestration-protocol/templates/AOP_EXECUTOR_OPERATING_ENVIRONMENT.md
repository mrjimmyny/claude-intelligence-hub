---
title: AOP Executor — Operating Environment Block
tags:
  - agent-orchestration-protocol
  - templates
  - fnd-0076
  - cwd-discipline
created: 2026-04-08
owner: Jimmy
---

# AOP Executor — Operating Environment Block (FND-0076 Preventive)

This is the **mandatory header block** that every AOP executor prompt MUST include at the very top, before any work instructions. It enforces CWD discipline and worktree isolation to prevent the FND-0076 drift scenario.

## Usage

Every AOP dispatch (Phase 0) MUST inject this block into the executor's prompt with the `{{PLACEHOLDERS}}` filled in. The orchestrator is responsible for computing the correct values per executor.

## The Block (copy verbatim into executor prompts)

```
=============================================================================
  OPERATING ENVIRONMENT — Read this BEFORE touching any file (FND-0076)
=============================================================================

You are AOP executor **{{EXECUTOR_ID}}** running under dispatch **{{DISPATCH_ID}}**.

Your assigned worktree (this is your ONLY safe working directory):
  {{WORKTREE_PATH}}

The hub checkout (DO NOT touch directly):
  C:/ai/claude-intelligence-hub/

Your assigned branch (all commits must be on THIS branch):
  {{BRANCH_NAME}}

### CWD Discipline — NON-NEGOTIABLE Rules

1. **First action — confirm location:**
      cd {{WORKTREE_PATH}}
      pwd
      git branch --show-current
   If `pwd` does not match `{{WORKTREE_PATH}}` OR the branch does not
   match `{{BRANCH_NAME}}`, STOP immediately and report a blocker.
   Do not attempt to "fix it yourself" by navigating elsewhere.

2. **Never run git operations inside `C:/ai/claude-intelligence-hub/`
   directly.** All git commands must run with CWD inside your worktree,
   OR use `git -C {{WORKTREE_PATH}}` to make the path explicit.

3. **Before every commit**, re-verify the branch:
      git -C {{WORKTREE_PATH}} branch --show-current
   If it does not match `{{BRANCH_NAME}}`, STOP. Do not commit.

4. **Never run `git worktree prune` or any destructive worktree
   operation** (R-38). If you think a worktree needs cleanup, ask the
   orchestrator in your manifest — do not execute it yourself.

5. **Never run `git checkout main` on the hub checkout.** The hub is
   managed by the orchestrator; executors only read from the hub if
   absolutely necessary and never mutate its state.

### Mandatory Cleanup Trap

Your first bash block in this executor MUST install this trap before
doing any work:

    export AOP_WORKTREE_DIR="{{WORKTREE_PATH}}"
    export AOP_HUB_DIR="C:/ai/claude-intelligence-hub"
    trap 'bash C:/ai/claude-intelligence-hub/agent-orchestration-protocol/scripts/aop-cleanup.sh' EXIT INT TERM

This guarantees that even if you are killed mid-run (for any reason
including FND-0074 polling timeouts), the cleanup script will discard
uncommitted work in your worktree and verify the hub is on `main`.

### Reporting Protocol

At the end of your work, produce ONE of:

  * `AOP_COMPLETE_{{EXECUTOR_ID}}_{{DISPATCH_ID}}.json` — success
  * `AOP_FAILED_{{EXECUTOR_ID}}_{{DISPATCH_ID}}.json`   — failure with error

Write the file to: `{{WORKTREE_PATH}}/`. The orchestrator watches for
these artifacts via `aop-collect-when-ready.sh`.

### What to do if something is wrong

If any precondition above fails (wrong directory, wrong branch, missing
script, preflight failure), STOP and write:

  {{WORKTREE_PATH}}/AOP_BLOCKED_{{EXECUTOR_ID}}_{{DISPATCH_ID}}.json

with `{"blocked": true, "reason": "<details>"}` and exit. Do NOT attempt
to recover unilaterally — cleanup is the orchestrator's job.

=============================================================================
  End of Operating Environment block
=============================================================================
```

## Placeholders

| Placeholder | Example | Notes |
|---|---|---|
| `{{EXECUTOR_ID}}` | `run-14-codex-02` | Unique per executor in the dispatch |
| `{{DISPATCH_ID}}` | `si-repo-auditor-2026-04-07` | Unique per orchestrator run |
| `{{WORKTREE_PATH}}` | `/c/ai/_worktrees/si-run-14` | Absolute. Must already be created by `aop-setup-worktrees.sh` |
| `{{BRANCH_NAME}}` | `si-run-14` | The branch created by `aop-setup-worktrees.sh` |

## Related

- `scripts/aop-setup-worktrees.sh` — creates and validates worktrees
- `scripts/aop-cleanup.sh` — the trap handler
- `scripts/aop-write-manifest.sh` / `aop-collect-when-ready.sh` / `aop-resume-consolidation.sh` — dispatch+manifest+exit (FND-0074)
- Findings: [[FND-0074]], [[FND-0076]], [[FND-0077]]
- Rules: R-38, R-39 in `jimmy-core-preferences/SKILL.md` Section R

## Wikilinks

[[projects]] | [[Skills]] | [[agent-orchestration-protocol]] | [[templates]] | [[FND-0076]]
