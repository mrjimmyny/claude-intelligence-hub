#!/usr/bin/env bash
# ============================================================
# aop-fan-in.sh — Fan-in aggregation
# ============================================================
#
# Purpose:  Reads all individual AOP_COMPLETE_{task_id}_{session_id}.json
#           artifacts and generates a single aggregation artifact:
#           AOP_FANIN_{session_id}.json. Handles partial success.
#
# Usage:    bash scripts/aop-fan-in.sh <session_id> <project_dir> \
#             <task_id:status> [task_id:status ...]
#
# Dependencies: bash 4+, jq (optional, for file extraction)
#
# Example:
#   bash scripts/aop-fan-in.sh a1b2c3d4 /c/ai/target-project \
#     "update-readme:COMPLETE" \
#     "update-changelog:COMPLETE" \
#     "run-tests:TIMEOUT"
#
# Output: AOP_FANIN_{session_id}.json in project_dir
# ============================================================
set -euo pipefail

if [ $# -lt 3 ]; then
  echo "Usage: $0 <session_id> <project_dir> <task_id:status> [...]" >&2
  exit 1
fi

SESSION_ID="$1"
PROJECT_DIR="$2"
shift 2

FANIN_FILE="${PROJECT_DIR}/AOP_FANIN_${SESSION_ID}.json"

# Parse task statuses
declare -a TASK_IDS
declare -A EXECUTOR_STATUS
for arg in "$@"; do
  tid="${arg%%:*}"
  status="${arg#*:}"
  TASK_IDS+=("$tid")
  EXECUTOR_STATUS["$tid"]="$status"
done

TOTAL=${#TASK_IDS[@]}
COMPLETED=0; FAILED=0; TIMED_OUT=0
TASKS_JSON=""
ALL_FILES=""

for tid in "${TASK_IDS[@]}"; do
  ARTIFACT="${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"
  status="${EXECUTOR_STATUS[$tid]}"

  duration="null"
  files="[]"
  artifact_ref="null"
  error="null"

  case "$status" in
    COMPLETE)
      COMPLETED=$((COMPLETED + 1))
      artifact_ref="\"AOP_COMPLETE_${tid}_${SESSION_ID}.json\""
      if command -v jq &>/dev/null && test -s "$ARTIFACT"; then
        files=$(jq -c '.files_changed // []' "$ARTIFACT" 2>/dev/null || echo '[]')
        ALL_FILES="${ALL_FILES},$(echo "$files" | tr -d '[]')"
      fi
      final_status="SUCCESS"
      ;;
    TIMEOUT)
      TIMED_OUT=$((TIMED_OUT + 1))
      error="\"Per-executor timeout reached\""
      final_status="TIMEOUT"
      ;;
    *)
      FAILED=$((FAILED + 1))
      error="\"Executor did not produce a valid artifact\""
      final_status="FAILURE"
      ;;
  esac

  [ -n "$TASKS_JSON" ] && TASKS_JSON="${TASKS_JSON},"
  TASKS_JSON="${TASKS_JSON}
    {\"task_id\":\"${tid}\",\"status\":\"${final_status}\",\"artifact\":${artifact_ref},\"duration_s\":${duration},\"files_changed\":${files}$([ "$error" != "null" ] && echo ",\"error\":${error}")}"
done

# Determine overall status
if [ "$COMPLETED" -eq "$TOTAL" ]; then
  OVERALL="SUCCESS"
elif [ "$COMPLETED" -eq 0 ]; then
  OVERALL="FAILURE"
else
  OVERALL="PARTIAL_SUCCESS"
fi

# Deduplicate aggregated files
if command -v jq &>/dev/null; then
  AGG_FILES=$(echo "[${ALL_FILES#,}]" | jq -c 'flatten | unique' 2>/dev/null || echo "[]")
else
  AGG_FILES="[${ALL_FILES#,}]"
fi

# Write fan-in artifact atomically
FANIN_TMP="${FANIN_FILE}.tmp.$$"
cat > "$FANIN_TMP" <<FANINEOF
{
  "session_id": "${SESSION_ID}",
  "total_tasks": ${TOTAL},
  "completed": ${COMPLETED},
  "failed": ${FAILED},
  "timed_out": ${TIMED_OUT},
  "overall_status": "${OVERALL}",
  "tasks": [${TASKS_JSON}
  ],
  "aggregated_files_changed": ${AGG_FILES},
  "fan_in_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
FANINEOF
mv -f "$FANIN_TMP" "$FANIN_FILE"

echo "=== Fan-In Report ==="
echo "Overall: ${OVERALL} (${COMPLETED}/${TOTAL} completed, ${FAILED} failed, ${TIMED_OUT} timed out)"
cat "$FANIN_FILE"
