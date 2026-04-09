#!/usr/bin/env bash
# ============================================================
# aop-collect-when-ready.sh — FND-0074 dispatch+manifest+exit watcher
# ============================================================
#
# Purpose:
#   Eliminate AOP polling waste. This script runs OUTSIDE any Claude Code
#   session (it is plain bash, no AI tokens) and waits for a set of
#   artifacts listed in a dispatch manifest. When all artifacts are
#   present, it optionally triggers a follow-up consolidation action.
#
#   This replaces the pattern where a live Claude Code headless session
#   ran `aop-multi-poll.sh` inside itself — burning paid tokens for the
#   entire duration of the wait (FND-0074, ~75-80% waste).
#
# The new pattern (Phase A/B/C):
#   Phase A: Sub-orchestrator dispatches agents, writes a manifest,
#            and calls exit. The CC session TERMINATES.
#   Phase B: An external process runs this script. No AI tokens consumed.
#            Cost = zero.
#   Phase C: When all artifacts are present, this script triggers
#            `aop-resume-consolidation.sh` (optional) which spawns a
#            fresh Claude session ONLY for consolidation.
#
# Usage:
#   bash aop-collect-when-ready.sh <manifest.json> [--on-ready <cmd>]
#
# Manifest format (JSON):
#   {
#     "dispatch_id": "run14",
#     "created_at": "2026-04-08T23:45:00-03:00",
#     "dispatched_by": "magneto",
#     "expected_artifacts": [
#       "AOP_COMPLETE_auth_a1b2.json",
#       "AOP_COMPLETE_ui_a1b2.json",
#       "AOP_COMPLETE_api_a1b2.json"
#     ],
#     "executor_pids": [12345, 12346, 12347],
#     "deadline_utc": "2026-04-09T03:45:00Z",
#     "next_phase": {
#       "type": "claude-consolidation",
#       "prompt_file": "aop-consolidate-run14.prompt"
#     }
#   }
#
#   Only `expected_artifacts` is strictly required. Other fields are
#   informational and forward-compatible.
#
# Environment variables (optional):
#   POLL_INTERVAL      seconds between sweeps (default: 10)
#   MAX_WAIT_SECONDS   hard timeout (default: 14400 = 4h)
#   VERBOSE            1 for per-sweep log line (default: 1)
#   LOG_FILE           path to append log lines (default: stderr)
#
# Exit codes:
#   0  — all artifacts present (and --on-ready succeeded if provided)
#   1  — timeout or missing artifacts
#   2  — manifest file not found or invalid
#   3  — --on-ready command failed
# ============================================================

set -u

SCRIPT_NAME="$(basename "$0")"

err() { printf '[%s] ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2; }
info() { printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2; }

if [ $# -lt 1 ]; then
  err "Usage: $0 <manifest.json> [--on-ready <command>]"
  exit 2
fi

MANIFEST="$1"
shift || true

ON_READY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --on-ready)
      ON_READY="${2:-}"
      shift 2 || true
      ;;
    --help|-h)
      sed -n '1,55p' "$0"
      exit 0
      ;;
    *)
      err "Unknown argument: $1"
      exit 2
      ;;
  esac
done

if [ ! -f "$MANIFEST" ]; then
  err "Manifest not found: $MANIFEST"
  exit 2
fi

POLL_INTERVAL="${POLL_INTERVAL:-10}"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-14400}"
VERBOSE="${VERBOSE:-1}"
LOG_FILE="${LOG_FILE:-}"

log() {
  local msg="[$SCRIPT_NAME $(date '+%Y-%m-%d %H:%M:%S')] $*"
  if [ -n "$LOG_FILE" ]; then
    printf '%s\n' "$msg" >> "$LOG_FILE"
  fi
  [ "$VERBOSE" = "1" ] && printf '%s\n' "$msg" >&2
}

# Parse expected_artifacts — prefer jq, fall back to a Python one-liner,
# then to a grep-based extractor as a last resort.
extract_artifacts() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '.expected_artifacts[]' "$MANIFEST"
    return
  fi
  if command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
    local PY
    PY=$(command -v python3 || command -v python)
    "$PY" -c "
import json, sys
with open('$MANIFEST', encoding='utf-8') as f:
    data = json.load(f)
for a in data.get('expected_artifacts', []):
    print(a)
"
    return
  fi
  # Last-resort grep-based extractor (tolerant of pretty-printed JSON).
  # Matches any string inside the expected_artifacts array.
  awk '
    /"expected_artifacts"/ { in_arr=1; next }
    in_arr && /\]/ { in_arr=0 }
    in_arr && /"[^"]+"/ {
      gsub(/^[[:space:]]*"/, "")
      gsub(/",?[[:space:]]*$/, "")
      if (length($0) > 0) print $0
    }
  ' "$MANIFEST"
}

ARTIFACTS=()
while IFS= read -r line; do
  # Strip CR (jq on Windows emits CRLF; makes test -f fail silently)
  line="${line%$'\r'}"
  [ -z "$line" ] && continue
  ARTIFACTS+=("$line")
done < <(extract_artifacts)

if [ "${#ARTIFACTS[@]}" -eq 0 ]; then
  err "Manifest has no expected_artifacts (or JSON is unparseable)"
  exit 2
fi

log "Manifest loaded: $MANIFEST"
log "Expecting ${#ARTIFACTS[@]} artifact(s):"
for a in "${ARTIFACTS[@]}"; do
  log "  - $a"
done
log "Poll interval: ${POLL_INTERVAL}s; max wait: ${MAX_WAIT_SECONDS}s"
log "Zero AI tokens consumed during wait (FND-0074 fix)."

start_ts=$(date '+%s' 2>/dev/null || echo "0")
elapsed=0
sweeps=0

while [ "$elapsed" -lt "$MAX_WAIT_SECONDS" ]; do
  sweeps=$((sweeps + 1))
  all_present=1
  present_count=0

  for a in "${ARTIFACTS[@]}"; do
    if [ -f "$a" ] && [ -s "$a" ]; then
      present_count=$((present_count + 1))
    else
      all_present=0
    fi
  done

  if [ "$all_present" -eq 1 ]; then
    log "ALL ${#ARTIFACTS[@]} ARTIFACTS READY after ${sweeps} sweep(s), ${elapsed}s elapsed."
    if [ -n "$ON_READY" ]; then
      log "Triggering --on-ready: $ON_READY"
      if ! bash -c "$ON_READY"; then
        err "--on-ready command failed"
        exit 3
      fi
    fi
    exit 0
  fi

  if [ $((sweeps % 6)) -eq 1 ]; then
    log "Progress: ${present_count}/${#ARTIFACTS[@]} ready, ${elapsed}s elapsed"
  fi

  sleep "$POLL_INTERVAL"
  now_ts=$(date '+%s' 2>/dev/null || echo "0")
  if [ "$start_ts" != "0" ] && [ "$now_ts" != "0" ]; then
    elapsed=$((now_ts - start_ts))
  else
    elapsed=$((elapsed + POLL_INTERVAL))
  fi
done

err "TIMEOUT after ${MAX_WAIT_SECONDS}s — only ${present_count}/${#ARTIFACTS[@]} artifacts present"
for a in "${ARTIFACTS[@]}"; do
  if [ -f "$a" ] && [ -s "$a" ]; then
    log "  READY:   $a"
  else
    log "  MISSING: $a"
  fi
done
exit 1
