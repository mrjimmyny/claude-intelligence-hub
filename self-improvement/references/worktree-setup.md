# Worktree Setup Reference

**Phase:** 1 — Setup
**Loaded:** Once, at session start
**Purpose:** Create and manage the isolated git worktree for a self-improvement execution cycle.

---

## Pre-Creation Check

Before creating the worktree, verify no execution is already in progress for this target.

```bash
git branch --list "self-improvement/<slug>-<YYYY-MM-DD>"
```

**If the branch exists → STOP:**
> "An execution is already in progress for this target. Wait for completion or discard the existing branch."

**If the branch does not exist → proceed to creation.**

---

## Branch and Directory Naming

Construct `<slug>` from the target:

| Target Type | Rule | Example Target | Example Slug |
|---|---|---|---|
| Directory | Use directory name as-is | `agent-orchestration-protocol` | `agent-orchestration-protocol` |
| File | Strip extension, use filename | `checkpoint-verify.sh` | `checkpoint-verify` |

Full names:
- **Branch:** `self-improvement/<slug>-<YYYY-MM-DD>`
- **Worktree directory:** `_worktrees/self-improvement-<slug>-<YYYY-MM-DD>`

Example (directory target, date 2026-03-28):
- Branch: `self-improvement/agent-orchestration-protocol-2026-03-28`
- Directory: `_worktrees/self-improvement-agent-orchestration-protocol-2026-03-28`

---

## Creation

```bash
git worktree add "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>" -b "self-improvement/<slug>-<YYYY-MM-DD>"
```

**Failure handling:** If `git worktree add` fails for ANY reason:
- Do NOT attempt to work on main.
- Do NOT attempt alternative paths or workarounds.
- STOP immediately with: `"Worktree creation failed: <error>. Cannot proceed."`

---

## Verification

After creation, verify all three conditions before proceeding:

1. Worktree directory exists at `_worktrees/self-improvement-<slug>-<YYYY-MM-DD>/`
2. Branch `self-improvement/<slug>-<YYYY-MM-DD>` is checked out in the worktree
3. Target files are accessible within the worktree

```bash
# 1 — Directory exists
ls "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>"

# 2 — Correct branch is active in worktree
git -C "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>" branch --show-current

# 3 — Target is reachable (example for a directory target)
ls "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>/<target-path>"
```

If any verification step fails → STOP with a descriptive error. Do not proceed.

---

## Working Directory

After successful creation and verification, ALL framework operations execute within:

```
_worktrees/self-improvement-<slug>-<YYYY-MM-DD>/
```

Never read, write, or commit to `main` during an active execution cycle.

---

## Cleanup

### Successful completion (approved or rejected)

```bash
git worktree remove "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>"
# Branch is retained: approved = merged into main; rejected = kept for reference
```

### Failure (crash, timeout, unrecoverable error)

```bash
git worktree remove --force "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>"
git branch -D "self-improvement/<slug>-<YYYY-MM-DD>"
```

Use `--force` and branch deletion together on failure to leave the workspace clean for a future retry.
