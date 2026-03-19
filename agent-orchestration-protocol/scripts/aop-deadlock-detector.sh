#!/usr/bin/env bash
# ============================================================
# aop-deadlock-detector.sh — Deadlock detection
# ============================================================
#
# Purpose:  4-stage escalation deadlock detector for multi-executor
#           DAG workflows. Tracks "progress" across consecutive
#           poll cycles and escalates when all executors are stuck.
#
# Usage:    source scripts/aop-deadlock-detector.sh
#           # In the polling loop:
#           check_deadlock "$progress"
#           deadlock_result=$?
#
# Dependencies: bash 4+ (associative arrays)
#               Requires TASK_IDS, TASK_STATUS, TASK_PID,
#               EXECUTOR_POLLS, MAX_POLLS_DEFAULT as globals.
#
# Example:
#   source scripts/aop-deadlock-detector.sh
#   # After each poll cycle:
#   progress="false"
#   # ... check executors, set progress="true" if any changed ...
#   check_deadlock "$progress"
#   if [ $? -eq 2 ]; then
#     echo "DEADLOCK: aborting"
#     break
#   fi
#
# Escalation stages:
#   NORMAL    — at least 1 executor progressed → reset counter
#   WARN      — 2 consecutive stall cycles → log warning
#   ESCALATE  — 3 cycles + all >50% timeout → log escalation
#   DEADLOCK  — 4 cycles → kill all, return 2
#
# Return codes:
#   0 — NORMAL (progress or below warn threshold)
#   1 — WARN or ESCALATE
#   2 — DEADLOCK (all running executors killed)
# ============================================================

STALL_COUNTER=0
DEADLOCK_THRESHOLD=${DEADLOCK_THRESHOLD:-4}
WARN_THRESHOLD=${WARN_THRESHOLD:-2}
ESCALATE_THRESHOLD=${ESCALATE_THRESHOLD:-3}

check_deadlock() {
  local progress_this_cycle="$1"  # "true" if any executor changed state

  if [ "$progress_this_cycle" == "true" ]; then
    STALL_COUNTER=0
    return 0  # NORMAL
  fi

  STALL_COUNTER=$((STALL_COUNTER + 1))

  if [ "$STALL_COUNTER" -ge "$DEADLOCK_THRESHOLD" ]; then
    echo "[$(date -u +%H:%M:%SZ)] DEADLOCK DETECTED: ${STALL_COUNTER} consecutive cycles with no progress" >&2
    echo "Killing all running executors..." >&2

    for tid in "${TASK_IDS[@]}"; do
      if [[ "${TASK_STATUS[$tid]}" == "RUNNING" ]]; then
        echo "  Killing exec_${tid} (PID ${TASK_PID[$tid]})" >&2
        kill "${TASK_PID[$tid]}" 2>/dev/null
        sleep 1
        kill -9 "${TASK_PID[$tid]}" 2>/dev/null
        TASK_STATUS["$tid"]="FAILED"
      fi
    done
    return 2  # DEADLOCK
  fi

  if [ "$STALL_COUNTER" -ge "$ESCALATE_THRESHOLD" ]; then
    local all_over_half=true
    for tid in "${TASK_IDS[@]}"; do
      [[ "${TASK_STATUS[$tid]}" != "RUNNING" ]] && continue
      local polls=${EXECUTOR_POLLS[$tid]:-0}
      local max=${MAX_POLLS_DEFAULT:-60}
      if [ "$polls" -lt $((max / 2)) ]; then
        all_over_half=false
        break
      fi
    done

    if $all_over_half; then
      echo "[$(date -u +%H:%M:%SZ)] ESCALATION: All running executors >50% timeout, ${STALL_COUNTER} stall cycles" >&2
    else
      echo "[$(date -u +%H:%M:%SZ)] WARNING: ${STALL_COUNTER} consecutive stall cycles (some executors still early)" >&2
    fi
    return 1  # WARN/ESCALATE
  fi

  if [ "$STALL_COUNTER" -ge "$WARN_THRESHOLD" ]; then
    echo "[$(date -u +%H:%M:%SZ)] WARNING: ${STALL_COUNTER} consecutive cycles with no progress" >&2
    return 1  # WARN
  fi

  return 0  # NORMAL
}
