#!/usr/bin/env bash
# ============================================================
# aop-claude-dispatch.sh — AOP dispatch adapter for Claude Code
#
# Purpose: Wraps AOP headless dispatch for Claude Code CLI.
#          Ensures correct flags are always used and provides
#          a clean, auditable dispatch entry point.
#
# Usage:
#   bash scripts/aop-claude-dispatch.sh <prompt_file> <artifact_path> [working_dir] [model]
#
# Arguments:
#   prompt_file   - Path to the AOP prompt file
#   artifact_path - Path where completion artifact should be written
#   working_dir   - Optional working directory (defaults to current dir)
#   model         - Optional model override (defaults to claude-sonnet-4-6)
#
# Example:
#   bash scripts/aop-claude-dispatch.sh \
#     /c/ai/temp/AOP_PROMPT_task1.md \
#     /c/ai/temp/AOP_COMPLETE_task1.json \
#     /c/ai
# ============================================================

set -euo pipefail

PROMPT_FILE="${1:?Usage: aop-claude-dispatch.sh <prompt_file> <artifact_path> [working_dir] [model]}"
ARTIFACT_PATH="${2:?Usage: aop-claude-dispatch.sh <prompt_file> <artifact_path> [working_dir] [model]}"
WORKING_DIR="${3:-$(pwd)}"
MODEL="${4:-claude-sonnet-4-6}"

# Validate inputs
if [ ! -f "$PROMPT_FILE" ]; then
  echo "ERROR: Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

# Change to working directory
cd "$WORKING_DIR" || { echo "ERROR: Cannot cd to $WORKING_DIR" >&2; exit 1; }

echo "=== AOP Claude Dispatch ==="
echo "Prompt:    $PROMPT_FILE"
echo "Artifact:  $ARTIFACT_PATH"
echo "WorkDir:   $WORKING_DIR"
echo "Model:     $MODEL"
echo "Time:      $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "==========================="

# Read prompt and pass to claude via stdin
cat "$PROMPT_FILE" | claude -p \
  --dangerously-skip-permissions \
  --model "$MODEL"

# Check if artifact was created
if [ -f "$ARTIFACT_PATH" ]; then
  echo ""
  echo "=== Artifact Written ==="
  cat "$ARTIFACT_PATH"
  echo ""
  echo "=== Dispatch Complete ==="
  exit 0
else
  echo ""
  echo "WARNING: Artifact not found at $ARTIFACT_PATH"
  echo "The executor may have completed but failed to write the artifact."
  echo "=== Dispatch Complete (no artifact) ==="
  exit 0
fi
