#!/usr/bin/env bash
# ============================================================
# aop-setup-worktrees.sh — FND-0076 preventive script
# ============================================================
#
# Purpose:
#   Create a set of AOP executor worktrees in EXACTLY ONE target
#   repository, with explicit validation at every step. Replaces the
#   inline worktree-creation logic that lived inside the dispatch
#   wrapper and caused FND-0076 on 2026-04-07 (12 of 16 worktrees
#   were created against the wrong repo because of implicit CWD).
#
# Guarantees (non-negotiable — this is why the script exists):
#
#   1. --repo <path> is MANDATORY. No CWD inference. If omitted,
#      the script refuses to run.
#   2. The target repo must be on branch `main` before any worktree
#      operation. If it is not, the script refuses and reports the
#      current branch.
#   3. The hub directory (claude-intelligence-hub/) MUST NOT be
#      cross-registered as a worktree of the parent repo (R-39).
#      The script calls worktree-preflight.sh and refuses if it fails.
#   4. Every `git worktree add` runs with an absolute `--repo` context:
#          git -C "$repo" worktree add <path> <branch>
#      NOT `cd "$repo" && git worktree add ...` (avoids silent CWD bugs).
#   5. After each creation, the script verifies the worktree was
#      registered by the intended repo (not a sibling repo).
#   6. Rollback on any failure: previously-created worktrees in this
#      run are removed if a later one fails, leaving the repo clean.
#
# Usage:
#   aop-setup-worktrees.sh \
#     --repo <absolute-path-to-repo> \
#     --base-branch <branch> \
#     --prefix <worktree-path-prefix> \
#     --count <N> \
#     [--dry-run]
#
# Example — create 4 worktrees in the hub for runs 01-04:
#   bash aop-setup-worktrees.sh \
#     --repo /c/ai/claude-intelligence-hub \
#     --base-branch main \
#     --prefix /c/ai/_worktrees/si-run \
#     --count 4
#
#   Creates:
#     /c/ai/_worktrees/si-run-01  (branch si-run-01, based on main)
#     /c/ai/_worktrees/si-run-02
#     /c/ai/_worktrees/si-run-03
#     /c/ai/_worktrees/si-run-04
#
#   All registered as worktrees of /c/ai/claude-intelligence-hub, with
#   verification after each creation.
#
# Exit codes:
#   0 — all worktrees created and verified
#   1 — validation failure before first creation (repo missing, wrong
#       branch, preflight fail)
#   2 — creation failed partway — rolled back all this run's worktrees
#   3 — usage error
# ============================================================

set -u

SCRIPT_NAME="$(basename "$0")"
info() { printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2; }
err()  { printf '[%s] ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2; }

REPO=""
BASE_BRANCH="main"
PREFIX=""
COUNT=""
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)        REPO="$2"; shift 2 ;;
    --base-branch) BASE_BRANCH="$2"; shift 2 ;;
    --prefix)      PREFIX="$2"; shift 2 ;;
    --count)       COUNT="$2"; shift 2 ;;
    --dry-run)     DRY_RUN=1; shift ;;
    -h|--help)     sed -n '1,55p' "$0"; exit 0 ;;
    *) err "Unknown argument: $1"; exit 3 ;;
  esac
done

# --- Validation ---
if [ -z "$REPO" ]; then
  err "--repo is MANDATORY (no CWD inference allowed — FND-0076)"
  exit 3
fi

if [ ! -d "$REPO/.git" ] && [ ! -f "$REPO/.git" ]; then
  err "Not a git repo or worktree: $REPO"
  exit 1
fi

if [ -z "$PREFIX" ] || [ -z "$COUNT" ]; then
  err "--prefix and --count are required"
  exit 3
fi

if ! [[ "$COUNT" =~ ^[0-9]+$ ]] || [ "$COUNT" -lt 1 ]; then
  err "--count must be a positive integer"
  exit 3
fi

# --- Guarantee 2: target repo is on main ---
CURRENT_BRANCH=$(git -C "$REPO" branch --show-current 2>/dev/null || echo "")
if [ "$CURRENT_BRANCH" != "$BASE_BRANCH" ]; then
  err "Target repo $REPO is on branch '$CURRENT_BRANCH' (expected '$BASE_BRANCH')"
  err "Refusing to create worktrees on a drifted repo (FND-0076 safety check)"
  exit 1
fi

# --- Guarantee 3: R-39 preflight ---
PREFLIGHT="/c/ai/_skills/daily-doc-information/scripts/worktree-preflight.sh"
if [ -f "$PREFLIGHT" ]; then
  info "Running R-39 preflight before worktree operations..."
  if ! bash "$PREFLIGHT" >&2; then
    err "worktree-preflight.sh FAILED. Refusing to proceed."
    err "Resolve the cross-registration drift before calling this script."
    exit 1
  fi
else
  err "WARN: preflight script not found at $PREFLIGHT — proceeding without R-39 check"
fi

# --- Worktree creation loop ---
CREATED=()
cleanup_on_error() {
  local rc=$?
  if [ ${#CREATED[@]} -gt 0 ]; then
    err "Rolling back ${#CREATED[@]} worktree(s) created during this run..."
    for wt in "${CREATED[@]}"; do
      info "  rollback: git -C \"$REPO\" worktree remove --force \"$wt\""
      git -C "$REPO" worktree remove --force "$wt" 2>/dev/null || true
    done
  fi
  exit $rc
}
trap 'cleanup_on_error' ERR

set -e

info "Repo: $REPO (branch: $CURRENT_BRANCH)"
info "Base branch: $BASE_BRANCH"
info "Prefix: $PREFIX"
info "Count: $COUNT"
[ "$DRY_RUN" -eq 1 ] && info "*** DRY RUN — no changes will be made ***"

for i in $(seq 1 "$COUNT"); do
  # Zero-pad to 2 digits
  IDX=$(printf '%02d' "$i")
  WT_PATH="${PREFIX}-${IDX}"
  WT_BRANCH="$(basename "$PREFIX")-${IDX}"

  info "--- Worktree $IDX ---"
  info "  path:   $WT_PATH"
  info "  branch: $WT_BRANCH (from $BASE_BRANCH)"

  if [ -e "$WT_PATH" ]; then
    err "  Path already exists: $WT_PATH"
    err "  Refusing to overwrite. Clean up before re-running."
    exit 2
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    info "  (dry-run — skipping creation)"
    continue
  fi

  # Guarantee 4: absolute -C invocation, no cd
  if ! git -C "$REPO" worktree add -b "$WT_BRANCH" "$WT_PATH" "$BASE_BRANCH" 2>&1 | sed 's/^/    /' >&2; then
    err "  git worktree add FAILED for $WT_PATH"
    exit 2
  fi

  # Guarantee 5: verify registration
  ABS_WT=$(cd "$WT_PATH" && pwd)
  if ! git -C "$REPO" worktree list | awk '{print $1}' | grep -Fxq "$ABS_WT"; then
    err "  Worktree $ABS_WT not registered in repo $REPO after creation"
    err "  Aborting — something is very wrong."
    exit 2
  fi

  info "  PASS: registered in $REPO"
  CREATED+=("$ABS_WT")
done

# Disarm rollback trap on clean exit
trap - ERR

info ""
info "=== aop-setup-worktrees.sh COMPLETE ==="
info "Created and verified ${#CREATED[@]} worktree(s) in $REPO"
for wt in "${CREATED[@]}"; do
  info "  $wt"
done
exit 0
