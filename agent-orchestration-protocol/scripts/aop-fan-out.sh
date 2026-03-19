#!/usr/bin/env bash
# ============================================================
# aop-fan-out.sh — Fan-out dispatch sequence
# ============================================================
#
# Purpose:  Parse a task manifest, validate write path isolation,
#           generate per-task prompts, initialize state file,
#           and launch all executors in parallel.
#
# Usage:    bash scripts/aop-fan-out.sh
#           (Configure TASKS array and PROJECT_DIR below before use)
#
# Dependencies: bash 4+ (associative arrays), claude CLI
#
# Example:
#   Edit TASKS array with your task definitions, then:
#   bash scripts/aop-fan-out.sh
#
# Output:
#   - AOP_PROMPT_{task_id}_{session_id}.md per executor
#   - AOP_STATE_{session_id}.json (orchestrator state)
#   - Executor PIDs printed to stdout
# ============================================================
set -euo pipefail

SESSION_ID="$(date +%s%N | sha256sum | head -c 8)"
PROJECT_DIR="${PROJECT_DIR:-/c/ai/target-project}"
STATE_FILE="${PROJECT_DIR}/AOP_STATE_${SESSION_ID}.json"

# --- Task manifest ---
# Format: "task_id:model:write_path"
# CUSTOMIZE THIS for your workflow
TASKS=(
  "update-readme:claude-sonnet-4-6:${PROJECT_DIR}/README.md"
  "update-changelog:claude-sonnet-4-6:${PROJECT_DIR}/CHANGELOG.md"
  "run-tests:claude-haiku-4-5:${PROJECT_DIR}/test-results/"
)

# --- Extract arrays from manifest ---
declare -a TASK_IDS MODELS WRITE_PATHS
for entry in "${TASKS[@]}"; do
  IFS=':' read -r tid model wpath <<< "$entry"
  TASK_IDS+=("$tid")
  MODELS+=("$model")
  WRITE_PATHS+=("$wpath")
done

# --- Validate write paths are disjoint (pairwise) ---
for i in "${!WRITE_PATHS[@]}"; do
  for j in "${!WRITE_PATHS[@]}"; do
    [ "$i" -ge "$j" ] && continue
    pa="${WRITE_PATHS[$i]}"
    pb="${WRITE_PATHS[$j]}"
    if [[ "$pb" == "$pa"* ]] || [[ "$pa" == "$pb"* ]]; then
      echo "ABORT: write path conflict between ${TASK_IDS[$i]} ('$pa') and ${TASK_IDS[$j]} ('$pb')" >&2
      exit 1
    fi
  done
done
echo "Write paths validated: no conflicts."

# --- Atomic state file writer ---
update_state() {
  local tmp="${STATE_FILE}.tmp.$$"
  cat > "$tmp" <<STATEEOF
$1
STATEEOF
  mv -f "$tmp" "$STATE_FILE"
}

# --- Initialize state file ---
EXECUTORS_JSON=""
for i in "${!TASK_IDS[@]}"; do
  [ -n "$EXECUTORS_JSON" ] && EXECUTORS_JSON="${EXECUTORS_JSON},"
  EXECUTORS_JSON="${EXECUTORS_JSON}
    {\"task_id\":\"${TASK_IDS[$i]}\",\"pid\":null,\"status\":\"PENDING\",\"model\":\"${MODELS[$i]}\",\"launched_at\":null,\"artifact_path\":\"${PROJECT_DIR}/AOP_COMPLETE_${TASK_IDS[$i]}_${SESSION_ID}.json\"}"
done

update_state "{
  \"session_id\":\"${SESSION_ID}\",
  \"workflow_type\":\"PARALLEL\",
  \"started_at\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
  \"executors\":[${EXECUTORS_JSON}
  ]
}"

# --- Generate prompts and launch ---
declare -A EXECUTOR_PID_MAP EXECUTOR_STATUS EXECUTOR_POLLS

for i in "${!TASK_IDS[@]}"; do
  tid="${TASK_IDS[$i]}"
  model="${MODELS[$i]}"
  wpath="${WRITE_PATHS[$i]}"
  PROMPT_FILE="${PROJECT_DIR}/AOP_PROMPT_${tid}_${SESSION_ID}.md"
  ARTIFACT="${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"

  cat > "${PROMPT_FILE}" <<PROMPTEOF
You are an Executor Agent. Working directory: ${PROJECT_DIR}

WRITE SCOPE (you may ONLY write to these paths):
- ${wpath}
- ${ARTIFACT}

TASK: [Insert task-specific instructions for ${tid} here]

COMPLETION REQUIREMENT:
As your LAST action, write: ${ARTIFACT}
{
  "status": "SUCCESS",
  "task_id": "${tid}",
  "session_id": "${SESSION_ID}",
  "executor_id": "exec_${tid}_${SESSION_ID}",
  "timestamp": "<ISO 8601>",
  "executor": "${model} (headless AOP)",
  "files_changed": ["<list of changed files>"]
}
PROMPTEOF

  cd "$PROJECT_DIR"
  cat "${PROMPT_FILE}" | claude -p --dangerously-skip-permissions --model "$model" &
  pid=$!
  EXECUTOR_PID_MAP["$tid"]=$pid
  EXECUTOR_STATUS["$tid"]="PENDING"
  EXECUTOR_POLLS["$tid"]=0
  echo "Launched: exec_${tid}_${SESSION_ID} (PID $pid, model $model)"
done

echo "Fan-out complete: ${#TASK_IDS[@]} executors dispatched."
echo "Session: ${SESSION_ID} | State file: ${STATE_FILE}"

# --- Enter multi-executor polling loop ---
# Use: bash scripts/aop-multi-poll.sh <artifact_files...>
# Or integrate the polling loop from aop-multi-poll.sh here.
