#!/usr/bin/env bash
# ============================================================
# aop-write-path-validator.sh — Pre-dispatch write path validation
# ============================================================
#
# Purpose:  Verify that write paths declared by multiple executors
#           are disjoint (no two executors write to the same file
#           or directory subtree). MUST pass before any parallel dispatch.
#
# Usage:    bash scripts/aop-write-path-validator.sh \
#             "exec_a:/path/a1,/path/a2" \
#             "exec_b:/path/b1,/path/b2"
#
#           Each argument is "executor_id:comma_separated_paths"
#
# Dependencies: bash 4+
#
# Example:
#   bash scripts/aop-write-path-validator.sh \
#     "task-auth:/c/ai/project/src/auth/,/c/ai/project/AOP_COMPLETE_auth.json" \
#     "task-ui:/c/ai/project/src/ui/,/c/ai/project/AOP_COMPLETE_ui.json"
#
# Exit codes:
#   0 — all paths are disjoint (safe to dispatch)
#   1 — conflict detected (ABORT)
# ============================================================
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 'exec_id:path1,path2' 'exec_id:path1,path2' [...]" >&2
  exit 1
fi

# Parse arguments into parallel arrays
declare -a EXEC_IDS
declare -a EXEC_PATHS

for arg in "$@"; do
  exec_id="${arg%%:*}"
  paths_csv="${arg#*:}"
  EXEC_IDS+=("$exec_id")
  EXEC_PATHS+=("$paths_csv")
done

# Pairwise disjoint check
conflicts=0
for i in "${!EXEC_IDS[@]}"; do
  IFS=',' read -ra paths_a <<< "${EXEC_PATHS[$i]}"
  for j in "${!EXEC_IDS[@]}"; do
    [ "$i" -ge "$j" ] && continue
    IFS=',' read -ra paths_b <<< "${EXEC_PATHS[$j]}"

    for pa in "${paths_a[@]}"; do
      for pb in "${paths_b[@]}"; do
        # Overlap: one path is a prefix of the other
        if [[ "$pb" == "$pa"* ]] || [[ "$pa" == "$pb"* ]]; then
          echo "CONFLICT: '${EXEC_IDS[$i]}' path '$pa' overlaps '${EXEC_IDS[$j]}' path '$pb'" >&2
          conflicts=$((conflicts + 1))
        fi
      done
    done
  done
done

if [ "$conflicts" -gt 0 ]; then
  echo "ABORT: $conflicts write path conflict(s) detected. Restructure tasks." >&2
  exit 1
fi

echo "Write paths validated: no conflicts."
exit 0
