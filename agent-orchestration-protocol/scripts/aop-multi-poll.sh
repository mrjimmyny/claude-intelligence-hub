#!/usr/bin/env bash
# ============================================================
# aop-multi-poll.sh — Multi-executor polling loop
# ============================================================
#
# Purpose:  Monitor N completion artifacts concurrently with
#           per-executor status tracking and timeout handling.
#           Reports completions as they arrive.
#
# Usage:    bash scripts/aop-multi-poll.sh artifact1.json artifact2.json ...
#
#           Environment variables (optional):
#             MAX_POLLS     — max polls per executor (default: 60)
#             POLL_INTERVAL — seconds between sweeps (default: 3)
#             EXECUTOR_PIDS — comma-separated PIDs to kill on timeout
#
# Dependencies: bash 4+ (associative arrays)
#
# Example:
#   export EXECUTOR_PIDS="12345,12346,12347"
#   bash scripts/aop-multi-poll.sh \
#     AOP_COMPLETE_auth_a1b2.json \
#     AOP_COMPLETE_ui_a1b2.json \
#     AOP_COMPLETE_api_a1b2.json
#
# Exit codes:
#   0 — all executors completed successfully
#   1 — one or more executors timed out
# ============================================================
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 artifact1.json artifact2.json ..." >&2
  exit 1
fi

MAX_POLLS="${MAX_POLLS:-60}"
POLL_INTERVAL="${POLL_INTERVAL:-3}"
ARTIFACTS=("$@")

# Parse PIDs (optional, comma-separated)
IFS=',' read -ra PIDS <<< "${EXECUTOR_PIDS:-}"

# Initialize tracking
declare -A STATUS POLLS
for i in "${!ARTIFACTS[@]}"; do
  STATUS["$i"]="PENDING"
  POLLS["$i"]=0
done

all_done() {
  for i in "${!ARTIFACTS[@]}"; do
    [[ "${STATUS[$i]}" == "PENDING" ]] && return 1
  done
  return 0
}

had_timeout=false

while ! all_done; do
  for i in "${!ARTIFACTS[@]}"; do
    [[ "${STATUS[$i]}" != "PENDING" ]] && continue

    artifact="${ARTIFACTS[$i]}"

    # Check completion
    if test -f "$artifact" && test -s "$artifact"; then
      STATUS["$i"]="COMPLETE"
      echo "[$(date -u +%H:%M:%SZ)] COMPLETE: ${artifact}"
      cat "$artifact"
      continue
    fi

    # Per-executor poll counter
    POLLS["$i"]=$(( POLLS[$i] + 1 ))

    if [ "${POLLS[$i]}" -ge "$MAX_POLLS" ]; then
      STATUS["$i"]="TIMEOUT"
      had_timeout=true
      echo "[$(date -u +%H:%M:%SZ)] TIMEOUT: ${artifact}"

      # Kill executor if PID was provided
      if [ -n "${PIDS[$i]:-}" ]; then
        pid="${PIDS[$i]}"
        echo "  Killing PID ${pid}..."
        kill "$pid" 2>/dev/null
        sleep 1
        kill -9 "$pid" 2>/dev/null
      fi
    fi
  done

  all_done || sleep "$POLL_INTERVAL"
done

# Summary
echo "=== Polling Summary ==="
for i in "${!ARTIFACTS[@]}"; do
  echo "  ${ARTIFACTS[$i]}: ${STATUS[$i]}"
done

$had_timeout && exit 1 || exit 0
