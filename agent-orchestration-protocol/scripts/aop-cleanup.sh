#!/usr/bin/env bash
# ============================================================
# aop-cleanup.sh — FND-0076 preventive: trap-based executor rollback
# ============================================================
#
# Purpose:
#   Run inside every AOP executor worktree via `trap aop-cleanup EXIT`.
#   When the executor exits (normally OR by kill/interrupt), this script
#   rolls back uncommitted work in the worktree and ensures the hub
#   checkout is left on `main`. This prevents the FND-0076 drift
#   scenario where a killed executor leaves the hub on a feature branch.
#
# Installation pattern — inside every executor script (or dispatch
# prompt that runs bash in an executor context):
#
#   #!/usr/bin/env bash
#   export AOP_WORKTREE_DIR="/c/ai/_worktrees/si-run-01"
#   export AOP_HUB_DIR="/c/ai/claude-intelligence-hub"
#   trap 'bash /c/ai/claude-intelligence-hub/agent-orchestration-protocol/scripts/aop-cleanup.sh' EXIT INT TERM
#
#   # ... executor work ...
#
# What cleanup does:
#   1. If AOP_WORKTREE_DIR is set and exists:
#        a. Try `git -C "$AOP_WORKTREE_DIR" reset --hard HEAD`
#           (discards uncommitted work in the worktree only)
#   2. If AOP_HUB_DIR is set and exists:
#        a. Check hub's current branch
#        b. If NOT main, log a WARNING and attempt `git checkout main`
#           (only if the hub working tree is clean)
#        c. If the hub tree is dirty, log a CRITICAL WARNING and do
#           NOT auto-checkout — a human must resolve
#   3. Log all actions to /c/ai/logs/aop-cleanup.log
#
# What cleanup does NOT do (by design):
#   * Never runs `git worktree prune` (blocked by R-38 + Option B shim)
#   * Never runs `git reset --hard` on the hub
#   * Never force-deletes worktrees
#   * Never touches branches other than the hub's current branch
#
# The script is intentionally DEFENSIVE and CONSERVATIVE. Its job is to
# leave the workspace in a safe state for the next run, not to forcibly
# clean every trace of the executor.
# ============================================================

set -u

LOG_FILE="${AOP_CLEANUP_LOG:-/c/ai/logs/aop-cleanup.log}"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

log() {
  local ts
  ts=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo unknown)
  printf '%s | aop-cleanup | pid=%s | user=%s | %s\n' \
    "$ts" "$$" "${USER:-${USERNAME:-unknown}}" "$*" >> "$LOG_FILE" 2>/dev/null
  printf '[aop-cleanup] %s\n' "$*" >&2
}

log "cleanup started (rc from caller=${?:-0}, AOP_WORKTREE_DIR=${AOP_WORKTREE_DIR:-<unset>}, AOP_HUB_DIR=${AOP_HUB_DIR:-<unset>})"

# --- Step 1: rollback uncommitted work in the executor worktree ---
if [ -n "${AOP_WORKTREE_DIR:-}" ]; then
  if [ -d "$AOP_WORKTREE_DIR" ]; then
    if git -C "$AOP_WORKTREE_DIR" rev-parse --git-dir >/dev/null 2>&1; then
      dirty=$(git -C "$AOP_WORKTREE_DIR" status --porcelain 2>/dev/null)
      if [ -n "$dirty" ]; then
        log "WORKTREE DIRTY in $AOP_WORKTREE_DIR — resetting to HEAD"
        git -C "$AOP_WORKTREE_DIR" reset --hard HEAD 2>&1 | sed 's/^/  /' | tee -a "$LOG_FILE" >&2 || true
      else
        log "worktree clean: $AOP_WORKTREE_DIR"
      fi
    else
      log "WARN: AOP_WORKTREE_DIR not a git repo: $AOP_WORKTREE_DIR"
    fi
  else
    log "WARN: AOP_WORKTREE_DIR does not exist: $AOP_WORKTREE_DIR"
  fi
else
  log "no AOP_WORKTREE_DIR set — skipping step 1"
fi

# --- Step 2: ensure hub is on main (defensive, non-destructive) ---
if [ -n "${AOP_HUB_DIR:-}" ]; then
  if [ -d "$AOP_HUB_DIR/.git" ]; then
    hub_branch=$(git -C "$AOP_HUB_DIR" branch --show-current 2>/dev/null || echo "unknown")
    if [ "$hub_branch" = "main" ]; then
      log "hub branch OK: main"
    elif [ -z "$hub_branch" ] || [ "$hub_branch" = "unknown" ]; then
      log "CRITICAL WARN: cannot determine hub branch — human review needed"
    else
      log "WARN: hub is on branch '$hub_branch' (expected main) — checking if safe to switch"
      hub_dirty=$(git -C "$AOP_HUB_DIR" status --porcelain 2>/dev/null)
      if [ -n "$hub_dirty" ]; then
        log "CRITICAL WARN: hub working tree is DIRTY on branch '$hub_branch'"
        log "               NOT auto-checking-out main — human must resolve"
      else
        log "hub tree clean — attempting checkout main"
        if git -C "$AOP_HUB_DIR" checkout main 2>&1 | sed 's/^/  /' | tee -a "$LOG_FILE" >&2; then
          log "hub restored to main"
        else
          log "CRITICAL WARN: git checkout main FAILED"
        fi
      fi
    fi
  else
    log "WARN: AOP_HUB_DIR not a git repo: $AOP_HUB_DIR"
  fi
else
  log "no AOP_HUB_DIR set — skipping step 2"
fi

log "cleanup complete"
exit 0
