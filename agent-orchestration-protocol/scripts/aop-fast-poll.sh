#!/usr/bin/env bash
# ============================================================
# aop-fast-poll.sh — Fast-polling loop (3s interval)
# ============================================================
#
# Purpose:  Simplified fast-polling pattern for event-driven
#           detection of AOP completion artifacts. Replaces
#           the adaptive 30/60s interval with a fixed 3s sweep.
#
# Usage:    bash scripts/aop-fast-poll.sh <artifact_path> [max_polls]
#
#           artifact_path — path to the AOP_COMPLETE_*.json to watch
#           max_polls     — maximum poll iterations (default: 60 = ~3 min)
#
# Dependencies: bash
#
# Example:
#   bash scripts/aop-fast-poll.sh AOP_COMPLETE_task1_a1b2.json 100
#
# Exit codes:
#   0 — artifact detected
#   1 — timeout reached
# ============================================================
set -euo pipefail

ARTIFACT="${1:?Usage: $0 <artifact_path> [max_polls]}"
MAX_POLLS="${2:-60}"
POLL_INTERVAL=3

POLLS=0
while [ "$POLLS" -lt "$MAX_POLLS" ]; do
  if test -f "$ARTIFACT" && test -s "$ARTIFACT"; then
    echo "[$(date -u +%H:%M:%SZ)] Artifact detected at poll ${POLLS}: ${ARTIFACT}"
    cat "$ARTIFACT"
    exit 0
  fi
  POLLS=$((POLLS + 1))
  echo "Poll ${POLLS}/${MAX_POLLS}: waiting..."
  sleep $POLL_INTERVAL
done

echo "TIMEOUT after ${MAX_POLLS} polls (${POLL_INTERVAL}s interval)."
exit 1
