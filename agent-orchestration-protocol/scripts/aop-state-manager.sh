#!/usr/bin/env bash
# ============================================================
# aop-state-manager.sh — Orchestrator state file management
# ============================================================
#
# Purpose:  Functions for managing the AOP_STATE_{session_id}.json
#           state file with atomic writes (write to temp, then mv).
#           Source this file to use the functions.
#
# Usage:    source scripts/aop-state-manager.sh
#           init_state "$STATE_FILE" "$SESSION_ID" "$WORKFLOW_TYPE"
#           update_executor_status "$STATE_FILE" "$TASK_ID" "COMPLETE"
#
# Dependencies: bash 4+ (associative arrays)
#
# Example:
#   source scripts/aop-state-manager.sh
#   STATE_FILE="/c/ai/project/AOP_STATE_a1b2c3d4.json"
#   update_state_file "$STATE_FILE" '{"session_id":"a1b2c3d4","status":"RUNNING"}'
# ============================================================

# Atomically update the state file (write to temp, then mv).
# Usage: update_state_file "$STATE_FILE" "$NEW_CONTENT"
update_state_file() {
  local state_file="$1"
  local content="$2"
  local tmp="${state_file}.tmp.$$"
  printf '%s\n' "$content" > "$tmp"
  mv -f "$tmp" "$state_file"
}

# Update executor state within the polling loop.
# Requires: TASK_IDS, EXECUTOR_STATUS, EXECUTOR_PID_MAP, MODELS,
#           LAUNCH_TIMES, SESSION_ID, PROJECT_DIR, STATE_FILE,
#           WORKFLOW_START as global variables.
# Usage: update_executor_state "$TASK_ID" "COMPLETE"
update_executor_state() {
  local tid="$1"
  local new_status="$2"  # COMPLETE, TIMEOUT, FAILURE

  EXECUTOR_STATUS[$tid]="$new_status"

  # Rebuild executors JSON from current state
  local exec_json=""
  for t in "${TASK_IDS[@]}"; do
    [ -n "$exec_json" ] && exec_json="${exec_json},"
    local completed_at="null"
    [[ "${EXECUTOR_STATUS[$t]}" != "PENDING" && "${EXECUTOR_STATUS[$t]}" != "RUNNING" ]] && \
      completed_at="\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
    exec_json="${exec_json}
      {\"task_id\":\"${t}\",\"pid\":${EXECUTOR_PID_MAP[$t]},\"status\":\"${EXECUTOR_STATUS[$t]}\",\"model\":\"${MODELS[$t]:-unknown}\",\"launched_at\":\"${LAUNCH_TIMES[$t]:-unknown}\",\"completed_at\":${completed_at},\"artifact_path\":\"${PROJECT_DIR}/AOP_COMPLETE_${t}_${SESSION_ID}.json\"}"
  done

  update_state_file "$STATE_FILE" "{
  \"session_id\":\"${SESSION_ID}\",
  \"workflow_type\":\"PARALLEL\",
  \"started_at\":\"${WORKFLOW_START}\",
  \"last_updated\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
  \"executors\":[${exec_json}
  ]
}"
}
