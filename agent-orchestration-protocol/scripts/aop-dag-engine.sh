#!/usr/bin/env bash
# ============================================================
# aop-dag-engine.sh — DAG execution engine
# ============================================================
#
# Purpose:  Execute tasks according to a dependency DAG with
#           topological ordering, priority-based dispatch,
#           bounded concurrency, and dependency failure propagation.
#
# Usage:    bash scripts/aop-dag-engine.sh
#           (Configure TASK_IDS, MODELS, PRIORITIES, WEIGHTS,
#            DEPENDS_ON, and PROJECT_DIR below before use)
#
# Dependencies: bash 4+ (associative arrays), claude CLI
#
# Example:
#   Edit the task manifest arrays, then:
#   bash scripts/aop-dag-engine.sh
#
# Algorithm:
#   1. Build adjacency list from task manifest
#   2. Validate DAG (no cycles) — uses detect_cycles()
#   3. Identify ready tasks (all deps satisfied)
#   4. Sort ready tasks by priority, then weight descending
#   5. Dispatch up to MAX_CONCURRENT
#   6. Poll, update state, find newly-ready tasks
#   7. Repeat until all settled
#   8. On failure, propagate to transitive dependents
# ============================================================
set -euo pipefail

SESSION_ID="$(date +%s%N | sha256sum | head -c 8)"
PROJECT_DIR="${PROJECT_DIR:-/c/ai/target-project}"
STATE_FILE="${PROJECT_DIR}/AOP_STATE_${SESSION_ID}.json"
MAX_CONCURRENT="${MAX_CONCURRENT:-4}"

# --- Task manifest (parallel arrays) ---
# CUSTOMIZE THESE for your workflow
TASK_IDS=("t1" "t2" "t3" "t4" "t5")
MODELS=("claude-sonnet-4-6" "claude-sonnet-4-6" "claude-opus-4-6" "claude-sonnet-4-6" "claude-sonnet-4-6")
PRIORITIES=("HIGH" "MEDIUM" "CRITICAL" "LOW" "MEDIUM")
WEIGHTS=(3 1 5 2 3)

# Dependency map: key=task_id, value=space-separated dependencies
declare -A DEPENDS_ON
DEPENDS_ON["t1"]=""
DEPENDS_ON["t2"]=""
DEPENDS_ON["t3"]="t1 t2"
DEPENDS_ON["t4"]="t1 t2"
DEPENDS_ON["t5"]="t3 t4"

# --- Status tracking ---
declare -A TASK_STATUS TASK_PID
for tid in "${TASK_IDS[@]}"; do
  TASK_STATUS["$tid"]="WAITING"  # WAITING | RUNNING | COMPLETE | FAILED | SKIPPED
  TASK_PID["$tid"]=""
done

# --- Cycle detection (from aop-dag-validator.sh) ---
detect_cycles() {
  declare -A COLOR  # WHITE=0, GRAY=1, BLACK=2
  declare -a CYCLE_PATH

  for tid in "${TASK_IDS[@]}"; do
    COLOR["$tid"]=0
  done

  dfs_visit() {
    local node="$1"
    COLOR["$node"]=1
    CYCLE_PATH+=("$node")

    for dep in ${DEPENDS_ON[$node]}; do
      if [ "${COLOR[$dep]}" -eq 1 ]; then
        echo "ERROR: Cycle detected in dependency graph!" >&2
        local cycle_str="" in_cycle=false
        for p in "${CYCLE_PATH[@]}"; do
          [ "$p" == "$dep" ] && in_cycle=true
          $in_cycle && cycle_str="${cycle_str} -> ${p}"
        done
        cycle_str="${cycle_str} -> ${dep}"
        echo "Cycle: ${cycle_str# -> }" >&2
        return 1
      elif [ "${COLOR[$dep]}" -eq 0 ]; then
        dfs_visit "$dep" || return 1
      fi
    done

    COLOR["$node"]=2
    unset 'CYCLE_PATH[-1]'
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

detect_cycles || { echo "ABORT: cycle detected in dependency graph" >&2; exit 1; }

# --- Priority comparator ---
priority_rank() {
  case "$1" in
    CRITICAL) echo 0 ;;
    HIGH)     echo 1 ;;
    MEDIUM)   echo 2 ;;
    LOW)      echo 3 ;;
    *)        echo 2 ;;
  esac
}

# --- Find ready tasks (all deps satisfied, not yet started) ---
find_ready_tasks() {
  local ready=()
  for tid in "${TASK_IDS[@]}"; do
    [[ "${TASK_STATUS[$tid]}" != "WAITING" ]] && continue

    local all_deps_met=true
    for dep in ${DEPENDS_ON[$tid]}; do
      case "${TASK_STATUS[$dep]}" in
        COMPLETE) ;;
        FAILED|SKIPPED)
          TASK_STATUS["$tid"]="SKIPPED"
          echo "[$(date -u +%H:%M:%SZ)] SKIPPED: ${tid} (dependency ${dep} ${TASK_STATUS[$dep]})"
          all_deps_met=false
          break
          ;;
        *)
          all_deps_met=false
          break
          ;;
      esac
    done

    [[ "${TASK_STATUS[$tid]}" == "SKIPPED" ]] && continue
    $all_deps_met && ready+=("$tid")
  done

  # Sort by priority rank (ascending), then weight (descending)
  if [ ${#ready[@]} -gt 0 ]; then
    for tid in "${ready[@]}"; do
      local idx=-1
      for i in "${!TASK_IDS[@]}"; do
        [[ "${TASK_IDS[$i]}" == "$tid" ]] && { idx=$i; break; }
      done
      local rank=$(priority_rank "${PRIORITIES[$idx]}")
      echo "$rank ${WEIGHTS[$idx]} $tid"
    done | sort -k1,1n -k2,2rn | awk '{print $3}'
  fi
}

# --- Count running executors ---
count_running() {
  local count=0
  for tid in "${TASK_IDS[@]}"; do
    [[ "${TASK_STATUS[$tid]}" == "RUNNING" ]] && count=$((count + 1))
  done
  echo "$count"
}

# --- Launch a single executor ---
launch_executor() {
  local tid="$1"
  local idx=-1
  for i in "${!TASK_IDS[@]}"; do
    [[ "${TASK_IDS[$i]}" == "$tid" ]] && { idx=$i; break; }
  done
  local model="${MODELS[$idx]}"
  local priority="${PRIORITIES[$idx]}"

  local PROMPT_FILE="${PROJECT_DIR}/AOP_PROMPT_${tid}_${SESSION_ID}.md"
  local ARTIFACT="${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"

  cat > "${PROMPT_FILE}" <<PEOF
You are an Executor Agent. Working directory: ${PROJECT_DIR}
Task ID: ${tid} | Priority: ${priority}

WRITE SCOPE (you may ONLY write to these paths):
- [task-specific write paths]
- ${ARTIFACT}

TASK: [Insert task-specific instructions for ${tid}]

COMPLETION REQUIREMENT:
As your LAST action, write: ${ARTIFACT}
{"status":"SUCCESS","task_id":"${tid}","session_id":"${SESSION_ID}","timestamp":"<ISO 8601>","executor":"${model} (headless AOP)","files_changed":["<list>"]}
PEOF

  cd "$PROJECT_DIR"
  cat "${PROMPT_FILE}" | claude -p --dangerously-skip-permissions --model "$model" &
  TASK_PID["$tid"]=$!
  TASK_STATUS["$tid"]="RUNNING"
  echo "[$(date -u +%H:%M:%SZ)] LAUNCHED: exec_${tid}_${SESSION_ID} (PID ${TASK_PID[$tid]}, model ${model}, priority ${priority})"
}

# --- Dependency failure propagation ---
propagate_failure() {
  local failed_tid="$1"
  local queue=("$failed_tid")

  while [ ${#queue[@]} -gt 0 ]; do
    local current="${queue[0]}"
    queue=("${queue[@]:1}")

    for tid in "${TASK_IDS[@]}"; do
      case "${TASK_STATUS[$tid]}" in
        COMPLETE|FAILED|SKIPPED) continue ;;
      esac

      for dep in ${DEPENDS_ON[$tid]}; do
        if [ "$dep" == "$current" ]; then
          TASK_STATUS["$tid"]="SKIPPED"
          echo "[$(date -u +%H:%M:%SZ)] SKIPPED: ${tid} (transitive dependency on failed task ${failed_tid})"
          [ -n "${TASK_PID[$tid]:-}" ] && kill "${TASK_PID[$tid]}" 2>/dev/null
          queue+=("$tid")
          break
        fi
      done
    done
  done
}

# --- Main DAG execution loop ---
POLL_INTERVAL=3
MAX_POLLS_DEFAULT=60  # 60 x 3s = 3 min
declare -A EXECUTOR_POLLS

dag_all_settled() {
  for tid in "${TASK_IDS[@]}"; do
    case "${TASK_STATUS[$tid]}" in
      WAITING|RUNNING) return 1 ;;
    esac
  done
  return 0
}

echo "=== DAG Execution Started (session: ${SESSION_ID}) ==="

while ! dag_all_settled; do
  # Dispatch ready tasks up to MAX_CONCURRENT
  running=$(count_running)
  if [ "$running" -lt "$MAX_CONCURRENT" ]; then
    slots=$((MAX_CONCURRENT - running))
    ready_list=$(find_ready_tasks)
    dispatched=0
    while IFS= read -r tid && [ "$dispatched" -lt "$slots" ]; do
      [ -z "$tid" ] && continue
      launch_executor "$tid"
      EXECUTOR_POLLS["$tid"]=0
      dispatched=$((dispatched + 1))
    done <<< "$ready_list"
  fi

  # Poll running executors for completion
  for tid in "${TASK_IDS[@]}"; do
    [[ "${TASK_STATUS[$tid]}" != "RUNNING" ]] && continue
    ARTIFACT="${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"

    if test -f "$ARTIFACT" && test -s "$ARTIFACT"; then
      TASK_STATUS["$tid"]="COMPLETE"
      echo "[$(date -u +%H:%M:%SZ)] COMPLETE: exec_${tid}_${SESSION_ID}"
      cat "$ARTIFACT"
      continue
    fi

    EXECUTOR_POLLS["$tid"]=$(( ${EXECUTOR_POLLS[$tid]:-0} + 1 ))

    # Priority-adjusted timeout
    idx=-1
    for i in "${!TASK_IDS[@]}"; do
      [[ "${TASK_IDS[$i]}" == "$tid" ]] && { idx=$i; break; }
    done
    max_polls=$MAX_POLLS_DEFAULT
    case "${PRIORITIES[$idx]}" in
      CRITICAL) max_polls=$((MAX_POLLS_DEFAULT * 2)) ;;
      LOW)      max_polls=$((MAX_POLLS_DEFAULT / 2)) ;;
    esac

    if [ "${EXECUTOR_POLLS[$tid]}" -ge "$max_polls" ]; then
      TASK_STATUS["$tid"]="FAILED"
      echo "[$(date -u +%H:%M:%SZ)] TIMEOUT/FAILED: exec_${tid}_${SESSION_ID}"
      kill "${TASK_PID[$tid]}" 2>/dev/null; sleep 1; kill -9 "${TASK_PID[$tid]}" 2>/dev/null
      propagate_failure "$tid"
    fi
  done

  dag_all_settled || sleep $POLL_INTERVAL
done

echo "=== DAG Execution Complete ==="
for tid in "${TASK_IDS[@]}"; do
  echo "  ${tid}: ${TASK_STATUS[$tid]}"
done
