#!/usr/bin/env bash
# ============================================================
# aop-write-manifest.sh — Helper for FND-0074 dispatch+manifest+exit
# ============================================================
#
# Purpose:
#   Called by a Claude Code headless sub-orchestrator immediately AFTER
#   dispatching its executors and IMMEDIATELY BEFORE exiting. Writes a
#   manifest that `aop-collect-when-ready.sh` can watch.
#
#   This script exists so CC sub-orchestrators don't need to emit JSON
#   by hand — they can call this helper and then exit cleanly.
#
# Usage:
#   aop-write-manifest.sh \
#     --manifest <path>        (required — output manifest path)
#     --dispatch-id <id>       (required)
#     --dispatched-by <name>   (required)
#     --deadline-utc <iso>     (optional, default: now + 4h)
#     --pids <csv>             (optional — comma-separated executor PIDs)
#     --next-phase-type <t>    (optional — hint for resume script)
#     --next-phase-prompt <p>  (optional — path to prompt file for Phase C)
#     --artifact <path>        (repeatable — one per dispatched executor)
#
# Example:
#   bash aop-write-manifest.sh \
#     --manifest /tmp/run14.manifest.json \
#     --dispatch-id run14 \
#     --dispatched-by magneto \
#     --pids "12345,12346,12347" \
#     --next-phase-type claude-consolidation \
#     --next-phase-prompt /tmp/consolidate-run14.prompt \
#     --artifact AOP_COMPLETE_auth.json \
#     --artifact AOP_COMPLETE_ui.json \
#     --artifact AOP_COMPLETE_api.json
#
# Output: writes the JSON manifest to the given path. Exits 0 on success.
# ============================================================

set -eu

MANIFEST=""
DISPATCH_ID=""
DISPATCHED_BY=""
DEADLINE_UTC=""
PIDS=""
NEXT_TYPE=""
NEXT_PROMPT=""
ARTIFACTS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --manifest)          MANIFEST="$2"; shift 2 ;;
    --dispatch-id)       DISPATCH_ID="$2"; shift 2 ;;
    --dispatched-by)     DISPATCHED_BY="$2"; shift 2 ;;
    --deadline-utc)      DEADLINE_UTC="$2"; shift 2 ;;
    --pids)              PIDS="$2"; shift 2 ;;
    --next-phase-type)   NEXT_TYPE="$2"; shift 2 ;;
    --next-phase-prompt) NEXT_PROMPT="$2"; shift 2 ;;
    --artifact)          ARTIFACTS+=("$2"); shift 2 ;;
    -h|--help)           sed -n '1,45p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$MANIFEST" ] || [ -z "$DISPATCH_ID" ] || [ -z "$DISPATCHED_BY" ] || [ "${#ARTIFACTS[@]}" -eq 0 ]; then
  echo "ERROR: --manifest, --dispatch-id, --dispatched-by, and at least one --artifact are required" >&2
  exit 2
fi

NOW_ISO=$(date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || date)

if [ -z "$DEADLINE_UTC" ]; then
  # default: now + 4h UTC
  if date -u -d '+4 hours' '+%Y-%m-%dT%H:%M:%SZ' >/dev/null 2>&1; then
    DEADLINE_UTC=$(date -u -d '+4 hours' '+%Y-%m-%dT%H:%M:%SZ')
  else
    DEADLINE_UTC="(not set)"
  fi
fi

# JSON string escaper (minimal — covers the fields we actually use)
esc() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

{
  printf '{\n'
  printf '  "dispatch_id": "%s",\n' "$(esc "$DISPATCH_ID")"
  printf '  "dispatched_by": "%s",\n' "$(esc "$DISPATCHED_BY")"
  printf '  "created_at": "%s",\n' "$(esc "$NOW_ISO")"
  printf '  "deadline_utc": "%s",\n' "$(esc "$DEADLINE_UTC")"
  if [ -n "$PIDS" ]; then
    printf '  "executor_pids": [%s],\n' "$PIDS"
  fi
  if [ -n "$NEXT_TYPE" ] || [ -n "$NEXT_PROMPT" ]; then
    printf '  "next_phase": {\n'
    printf '    "type": "%s",\n' "$(esc "$NEXT_TYPE")"
    printf '    "prompt_file": "%s"\n' "$(esc "$NEXT_PROMPT")"
    printf '  },\n'
  fi
  printf '  "expected_artifacts": [\n'
  last_idx=$((${#ARTIFACTS[@]} - 1))
  for i in "${!ARTIFACTS[@]}"; do
    if [ "$i" -eq "$last_idx" ]; then
      printf '    "%s"\n' "$(esc "${ARTIFACTS[$i]}")"
    else
      printf '    "%s",\n' "$(esc "${ARTIFACTS[$i]}")"
    fi
  done
  printf '  ]\n'
  printf '}\n'
} > "$MANIFEST"

echo "Manifest written: $MANIFEST (${#ARTIFACTS[@]} artifact(s))"
