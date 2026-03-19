#!/usr/bin/env bash
# ============================================================
# aop-codex-dispatch.sh — AOP dispatch adapter for Codex (Windows)
#
# Purpose: Wraps AOP headless dispatch for Codex CLI on Windows.
#          Codex on Windows runs bash inside PowerShell, causing
#          escaping failures with complex inline commands.
#          This script provides a clean bash entry point.
#
# Usage:
#   bash scripts/aop-codex-dispatch.sh <prompt_file> <artifact_path> [working_dir]
#
# Arguments:
#   prompt_file   - Path to the AOP prompt file (AOP_PROMPT_*.md)
#   artifact_path - Path where completion artifact should be written
#   working_dir   - Optional working directory (defaults to current dir)
#
# Cross-machine: Uses relative paths from script location.
#                 No hardcoded user paths. Works on any machine
#                 where C:\ai\ (or /c/ai/) exists.
#
# Example:
#   bash scripts/aop-codex-dispatch.sh \
#     /c/ai/temp/AOP_PROMPT_task1.md \
#     /c/ai/temp/AOP_COMPLETE_task1.json \
#     /c/ai/claude-intelligence-hub
# ============================================================

set -euo pipefail

PROMPT_FILE="${1:?Usage: aop-codex-dispatch.sh <prompt_file> <artifact_path> [working_dir]}"
ARTIFACT_PATH="${2:?Usage: aop-codex-dispatch.sh <prompt_file> <artifact_path> [working_dir]}"
WORKING_DIR="${3:-$(pwd)}"

# Validate inputs
if [ ! -f "$PROMPT_FILE" ]; then
  echo "ERROR: Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

# Change to working directory
cd "$WORKING_DIR" || { echo "ERROR: Cannot cd to $WORKING_DIR" >&2; exit 1; }

echo "=== AOP Codex Dispatch ==="
echo "Prompt:    $PROMPT_FILE"
echo "Artifact:  $ARTIFACT_PATH"
echo "WorkDir:   $WORKING_DIR"
echo "Time:      $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "=========================="

# Read prompt and pass to codex exec via stdin
# This avoids all escaping issues — the prompt file is read as-is
cat "$PROMPT_FILE" | codex exec \
  --model gpt-5.4 \
  --dangerously-bypass-approvals-and-sandbox \
  -C "$WORKING_DIR"

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
