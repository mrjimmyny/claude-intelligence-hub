#!/usr/bin/env bash
# ============================================================
# aop-dag-validator.sh — DAG cycle detection
# ============================================================
#
# Purpose:  DFS-based cycle detection using three-color marking.
#           Validates that a task dependency graph is a valid DAG
#           (no circular dependencies). Reports the cycle path
#           on failure.
#
# Usage:    source scripts/aop-dag-validator.sh
#           detect_cycles   # uses TASK_IDS and DEPENDS_ON globals
#
# Dependencies: bash 4+ (associative arrays)
#
# Example:
#   TASK_IDS=("t1" "t2" "t3")
#   declare -A DEPENDS_ON
#   DEPENDS_ON["t1"]=""
#   DEPENDS_ON["t2"]="t1"
#   DEPENDS_ON["t3"]="t2"
#   source scripts/aop-dag-validator.sh
#   detect_cycles && echo "Valid DAG" || echo "Cycle found!"
#
# Algorithm:
#   - WHITE (0): unvisited
#   - GRAY (1): in current DFS path
#   - BLACK (2): fully processed
#   - If DFS visits a GRAY node, a cycle exists
#
# Exit codes (via return):
#   0 — no cycles, valid DAG
#   1 — cycle detected (path printed to stderr)
# ============================================================

detect_cycles() {
  declare -A COLOR  # WHITE=0, GRAY=1, BLACK=2
  declare -a CYCLE_PATH

  for tid in "${TASK_IDS[@]}"; do
    COLOR["$tid"]=0
  done

  dfs_visit() {
    local node="$1"
    COLOR["$node"]=1  # GRAY — currently visiting
    CYCLE_PATH+=("$node")

    for dep in ${DEPENDS_ON[$node]}; do
      if [ "${COLOR[$dep]}" -eq 1 ]; then
        # Found a cycle — dep is in the current DFS path
        echo "ERROR: Cycle detected in dependency graph!" >&2
        local cycle_str=""
        local in_cycle=false
        for p in "${CYCLE_PATH[@]}"; do
          if [ "$p" == "$dep" ]; then
            in_cycle=true
          fi
          $in_cycle && cycle_str="${cycle_str} -> ${p}"
        done
        cycle_str="${cycle_str} -> ${dep}"
        echo "Cycle: ${cycle_str# -> }" >&2
        return 1
      elif [ "${COLOR[$dep]}" -eq 0 ]; then
        dfs_visit "$dep" || return 1
      fi
      # BLACK (2) nodes are fully processed — skip
    done

    COLOR["$node"]=2  # BLACK — done
    unset 'CYCLE_PATH[-1]'  # pop
    return 0
  }

  for tid in "${TASK_IDS[@]}"; do
    if [ "${COLOR[$tid]}" -eq 0 ]; then
      dfs_visit "$tid" || return 1
    fi
  done

  echo "DAG validation passed: no cycles detected."
  return 0
}
