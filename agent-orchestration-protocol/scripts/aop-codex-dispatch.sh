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
#   bash scripts/aop-codex-dispatch.sh <prompt_file> <artifact_path> [working_dir] [model]
#
# Arguments:
#   prompt_file   - Path to the AOP prompt file (AOP_PROMPT_*.md)
#   artifact_path - Path where completion artifact should be written
#   working_dir   - Optional working directory (defaults to current dir)
#   model         - Optional model override (defaults to gpt-5.2-codex)
#
# Model selection (official Codex routing — March 2026):
#   gpt-5.4          - Architecture, planning, reasoning (Tier 1)
#   gpt-5.3-codex    - Complex multi-step, multi-agent orchestration (Tier 1.5)
#   gpt-5.2-codex    - Standard coding, implementation (Tier 2 — DEFAULT)
#   gpt-5.4-mini     - Light reasoning with speed (Tier 2)
#   gpt-5.1-codex    - High stability, consistent output (Tier 2.5)
#   gpt-5.1-codex-max - Large context, many files, long sessions (Tier 2.5)
#   gpt-5-codex-mini  - Simple, repetitive, fast (Tier 3)
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
#
#   # With explicit model override:
#   bash scripts/aop-codex-dispatch.sh \
#     /c/ai/temp/AOP_PROMPT_task1.md \
#     /c/ai/temp/AOP_COMPLETE_task1.json \
#     /c/ai/claude-intelligence-hub \
#     gpt-5.3-codex
# ============================================================

set -euo pipefail

PROMPT_FILE="${1:?Usage: aop-codex-dispatch.sh <prompt_file> <artifact_path> [working_dir] [model]}"
ARTIFACT_PATH="${2:?Usage: aop-codex-dispatch.sh <prompt_file> <artifact_path> [working_dir] [model]}"
WORKING_DIR="${3:-$(pwd)}"
MODEL="${4:-gpt-5.2-codex}"

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
echo "Model:     $MODEL"
echo "Time:      $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "=========================="

# Read prompt and pass to codex exec via stdin
# This avoids all escaping issues — the prompt file is read as-is
cat "$PROMPT_FILE" | codex exec \
  --model "$MODEL" \
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
