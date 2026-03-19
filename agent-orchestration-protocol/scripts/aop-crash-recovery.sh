#!/usr/bin/env bash
# ============================================================
# aop-crash-recovery.sh — Crash recovery protocol
# ============================================================
#
# Purpose:  If the Orchestrator process crashes or is restarted
#           mid-workflow, this script reads AOP_STATE_*.json files
#           to reconstruct state, checks which executors are still
#           running, and resumes monitoring.
#
# Usage:    bash scripts/aop-crash-recovery.sh [project_dir]
#
# Dependencies: bash 4+, jq
#
# Example:
#   bash scripts/aop-crash-recovery.sh /c/ai/target-project
#
# Algorithm:
#   1. Scan for AOP_STATE_*.json files in the project directory
#   2. For each state file, parse executor entries
#   3. Check which executors are still running (kill -0 $PID)
#   4. Check for completion artifacts from executors that finished
#   5. Resume the polling loop for any still-running executors
#   6. Report recovered state before continuing
# ============================================================
set -euo pipefail

PROJECT_DIR="${1:-/c/ai/target-project}"

recover_session() {
  local state_file="$1"
  echo "=== Recovering from: ${state_file} ==="

  # Parse state file (requires jq)
  if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required for crash recovery. Install it and retry." >&2
    return 1
  fi

  local session_id
  session_id=$(jq -r '.session_id' "$state_file")
  local executor_count
  executor_count=$(jq '.executors | length' "$state_file")

  echo "Session: ${session_id} | Executors: ${executor_count}"

  # Re-initialize tracking arrays
  declare -A EXECUTOR_STATUS EXECUTOR_PID_MAP
  local -a TASK_IDS=()
  local running=0 completed=0 dead=0

  for idx in $(seq 0 $((executor_count - 1))); do
    local tid pid artifact_path prev_status
    tid=$(jq -r ".executors[$idx].task_id" "$state_file")
    pid=$(jq -r ".executors[$idx].pid" "$state_file")
    artifact_path=$(jq -r ".executors[$idx].artifact_path" "$state_file")
    prev_status=$(jq -r ".executors[$idx].status" "$state_file")

    TASK_IDS+=("$tid")
    EXECUTOR_PID_MAP["$tid"]=$pid

    # Already settled in state file?
    if [[ "$prev_status" == "COMPLETE" || "$prev_status" == "TIMEOUT" || "$prev_status" == "FAILURE" ]]; then
      EXECUTOR_STATUS["$tid"]="$prev_status"
      echo "  ${tid}: already ${prev_status} (from state file)"
      completed=$((completed + 1))
      continue
    fi

    # Check if process is still alive
    if kill -0 "$pid" 2>/dev/null; then
      if test -f "$artifact_path" && test -s "$artifact_path"; then
        EXECUTOR_STATUS["$tid"]="COMPLETE"
        echo "  ${tid}: COMPLETE (artifact found, PID $pid still running)"
        completed=$((completed + 1))
      else
        EXECUTOR_STATUS["$tid"]="PENDING"
        echo "  ${tid}: RUNNING (PID $pid alive, no artifact yet)"
        running=$((running + 1))
      fi
    else
      if test -f "$artifact_path" && test -s "$artifact_path"; then
        EXECUTOR_STATUS["$tid"]="COMPLETE"
        echo "  ${tid}: COMPLETE (PID $pid exited, artifact found)"
        completed=$((completed + 1))
      else
        EXECUTOR_STATUS["$tid"]="FAILURE"
        echo "  ${tid}: FAILURE (PID $pid exited, no artifact — executor crashed)"
        dead=$((dead + 1))
      fi
    fi
  done

  echo ""
  echo "Recovery summary: ${completed} settled, ${running} still running, ${dead} crashed"

  # Resume polling for still-running executors
  if [ "$running" -gt 0 ]; then
    echo "Resuming polling loop for ${running} executor(s)..."
    local MAX_POLLS=60
    local POLL_INTERVAL=3

    all_done() {
      for t in "${TASK_IDS[@]}"; do
        [[ "${EXECUTOR_STATUS[$t]}" == "PENDING" ]] && return 1
      done
      return 0
    }

    declare -A EXECUTOR_POLLS
    for t in "${TASK_IDS[@]}"; do
      EXECUTOR_POLLS["$t"]=0
    done

    while ! all_done; do
      for tid in "${TASK_IDS[@]}"; do
        [[ "${EXECUTOR_STATUS[$tid]}" != "PENDING" ]] && continue
        artifact="${PROJECT_DIR}/AOP_COMPLETE_${tid}_${session_id}.json"
        if test -f "$artifact" && test -s "$artifact"; then
          EXECUTOR_STATUS[$tid]="COMPLETE"
          echo "[$(date -u +%H:%M:%SZ)] RECOVERED COMPLETE: exec_${tid}_${session_id}"
          continue
        fi
        EXECUTOR_POLLS[$tid]=$(( EXECUTOR_POLLS[$tid] + 1 ))
        if [ "${EXECUTOR_POLLS[$tid]}" -ge $MAX_POLLS ]; then
          EXECUTOR_STATUS[$tid]="TIMEOUT"
          echo "[$(date -u +%H:%M:%SZ)] TIMEOUT (post-recovery): exec_${tid}_${session_id}"
          kill "${EXECUTOR_PID_MAP[$tid]}" 2>/dev/null
          sleep 1
          kill -9 "${EXECUTOR_PID_MAP[$tid]}" 2>/dev/null
        fi
      done
      all_done || sleep $POLL_INTERVAL
    done
  fi

  echo "=== Recovery complete for session ${session_id} ==="
  # Proceed to fan-in aggregation
}

# --- Entry point: scan for state files ---
STATE_FILES=(${PROJECT_DIR}/AOP_STATE_*.json)
if [ ! -f "${STATE_FILES[0]}" ]; then
  echo "No AOP_STATE_*.json files found. Nothing to recover."
  exit 0
fi

for sf in "${STATE_FILES[@]}"; do
  recover_session "$sf"
done
