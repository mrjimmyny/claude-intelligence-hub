#!/usr/bin/env bash
# ============================================================
# aop-priority-queue.sh — Task priority and bounded concurrency
# ============================================================
#
# Purpose:  Priority comparator (CRITICAL > HIGH > MEDIUM > LOW)
#           with weight-based secondary sort, and a bounded
#           concurrency dispatch queue (MAX_CONCURRENT).
#
# Usage:    source scripts/aop-priority-queue.sh
#           sorted=$(sort_by_priority "t1" "t2" "t3")
#           dispatch_ready_tasks
#
# Dependencies: bash 4+ (associative arrays)
#               Requires TASK_IDS, PRIORITIES, WEIGHTS, TASK_STATUS,
#               EXECUTOR_POLLS as globals. Also requires
#               find_ready_tasks(), launch_executor(), count_running()
#               from aop-dag-engine.sh.
#
# Example:
#   source scripts/aop-priority-queue.sh
#   MAX_CONCURRENT=4
#   sorted=$(sort_by_priority "t1" "t2" "t3")
#   echo "$sorted"  # prints task IDs sorted by priority
# ============================================================

MAX_CONCURRENT=${MAX_CONCURRENT:-4}

# --- Priority comparator ---
# Returns priority rank (lower = higher priority)
priority_rank() {
  case "$1" in
    CRITICAL) echo 0 ;;
    HIGH)     echo 1 ;;
    MEDIUM)   echo 2 ;;
    LOW)      echo 3 ;;
    *)        echo 2 ;;  # default to MEDIUM
  esac
}

# --- Sort task IDs by priority (ascending) then weight (descending) ---
sort_by_priority() {
  local tasks=("$@")
  for tid in "${tasks[@]}"; do
    for i in "${!TASK_IDS[@]}"; do
      if [[ "${TASK_IDS[$i]}" == "$tid" ]]; then
        local rank=$(priority_rank "${PRIORITIES[$i]:-MEDIUM}")
        local weight="${WEIGHTS[$i]:-3}"
        echo "${rank} ${weight} ${tid}"
        break
      fi
    done
  done | sort -k1,1n -k2,2rn | awk '{print $3}'
}

# --- Bounded concurrency dispatch ---
# Called each cycle after checking completions.
dispatch_ready_tasks() {
  local running=$(count_running)
  local available_slots=$((MAX_CONCURRENT - running))

  if [ "$available_slots" -le 0 ]; then
    return 0  # all slots full
  fi

  local ready_sorted
  ready_sorted=$(find_ready_tasks)
  [ -z "$ready_sorted" ] && return 0

  local dispatched=0
  while IFS= read -r tid; do
    [ -z "$tid" ] && continue
    [ "$dispatched" -ge "$available_slots" ] && break

    launch_executor "$tid"
    EXECUTOR_POLLS["$tid"]=0
    dispatched=$((dispatched + 1))
  done <<< "$ready_sorted"

  [ "$dispatched" -gt 0 ] && echo "[$(date -u +%H:%M:%SZ)] Dispatched ${dispatched} task(s), ${running} already running, ${MAX_CONCURRENT} max"
}

# --- Concurrency tracking ---
count_running() {
  local n=0
  for tid in "${TASK_IDS[@]}"; do
    [[ "${TASK_STATUS[$tid]}" == "RUNNING" ]] && n=$((n + 1))
  done
  echo "$n"
}
