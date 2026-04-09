#!/usr/bin/env bash
# ============================================================
# aop-resume-consolidation.sh — Phase C launcher (FND-0074)
# ============================================================
#
# Purpose:
#   Starts a fresh Claude Code headless session for the CONSOLIDATION
#   phase ONLY, after `aop-collect-when-ready.sh` has confirmed that all
#   executor artifacts are present. The new session runs for a short
#   time and exits — it does not poll, wait, or idle.
#
#   This is Phase C of the FND-0074 fix (dispatch+manifest+exit pattern).
#
# Typical invocation — chained from the collector:
#
#   bash aop-collect-when-ready.sh run14.manifest.json \
#     --on-ready "bash aop-resume-consolidation.sh run14.manifest.json consolidate-run14.prompt"
#
# Usage:
#   aop-resume-consolidation.sh <manifest.json> <consolidation-prompt.md> [--model MODEL] [--dry-run]
#
# Arguments:
#   manifest.json             the dispatch manifest produced by
#                             aop-write-manifest.sh
#   consolidation-prompt.md   the prompt text for the fresh Claude session.
#                             Must already reference the artifacts (paths
#                             can be the same as in the manifest).
#
# Options:
#   --model <id>   Claude model to use (default: claude-opus-4-6)
#   --dry-run      Print what would be launched and exit 0
#
# Exit codes:
#   0   — Claude session exited successfully
#   1   — Claude session failed (non-zero exit)
#   2   — usage error / missing input
#   3   — `claude` CLI not found in PATH
# ============================================================

set -eu

if [ $# -lt 2 ]; then
  echo "Usage: $0 <manifest.json> <consolidation-prompt.md> [--model MODEL] [--dry-run]" >&2
  exit 2
fi

MANIFEST="$1"
PROMPT_FILE="$2"
shift 2

MODEL="${MODEL_OVERRIDE:-claude-opus-4-6}"
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --model)   MODEL="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '1,50p' "$0"; exit 0 ;;
    *)         echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ ! -f "$MANIFEST" ]; then
  echo "ERROR: manifest not found: $MANIFEST" >&2
  exit 2
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "ERROR: consolidation prompt not found: $PROMPT_FILE" >&2
  exit 2
fi

if ! command -v claude >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne 1 ]; then
    echo "ERROR: 'claude' CLI not found in PATH" >&2
    echo "       Install Claude Code or add it to PATH before running this script." >&2
    exit 3
  fi
fi

PROMPT=$(cat "$PROMPT_FILE")

# Append a minimal header so the fresh session knows it is Phase C.
HEADER="# AOP Phase C — Consolidation Only

You have been invoked by aop-resume-consolidation.sh after all executor
artifacts listed in $MANIFEST are present.

Your job: run the consolidation below. Do NOT wait for additional executors,
do NOT dispatch new agents, do NOT poll. Exit as soon as the consolidation
output is written.
"

FULL_PROMPT="${HEADER}
${PROMPT}"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN ==="
  echo "Model: $MODEL"
  echo "Manifest: $MANIFEST"
  echo "Prompt file: $PROMPT_FILE"
  echo "Prompt length: $(printf '%s' "$FULL_PROMPT" | wc -c) bytes"
  echo "Launch command (not executed):"
  echo "  claude --print --model '$MODEL' '<prompt from $PROMPT_FILE + phase C header>'"
  exit 0
fi

echo "[aop-resume-consolidation] launching fresh Claude session (model=$MODEL)" >&2
echo "[aop-resume-consolidation] manifest=$MANIFEST" >&2
echo "[aop-resume-consolidation] prompt=$PROMPT_FILE" >&2

claude --print --model "$MODEL" "$FULL_PROMPT"
rc=$?

if [ "$rc" -ne 0 ]; then
  echo "[aop-resume-consolidation] Claude session exited with code $rc" >&2
  exit 1
fi

echo "[aop-resume-consolidation] consolidation complete" >&2
exit 0
