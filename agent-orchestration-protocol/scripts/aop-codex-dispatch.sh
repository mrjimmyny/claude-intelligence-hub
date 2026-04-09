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
#   bash scripts/aop-codex-dispatch.sh <prompt_file> <artifact_path> [working_dir] [model] [effort]
#
# Arguments:
#   prompt_file   - Path to the AOP prompt file (AOP_PROMPT_*.md)
#   artifact_path - Path where completion artifact should be written
#   working_dir   - Optional working directory (defaults to current dir)
#   model         - Optional model override (defaults to gpt-5.4)
#   effort        - Optional reasoning effort override (minimal|low|medium|high|xhigh).
#                   Defaults to medium. Only gpt-5.4 supports xhigh.
#                   Passed via: -c model_reasoning_effort="<effort>"
#
# Model selection (official Codex routing — April 2026, post-FND-0078):
#   gpt-5.4             - Architecture / planning / reasoning (Tier 1, effort=high|xhigh)
#                         AND Standard coding / balanced dev (Tier 2 Core, effort=medium — DEFAULT)
#   gpt-5.3-codex       - Complex software engineering, multi-step workflows,
#                         multi-agent orchestration, critical patches (Tier 1.5)
#   gpt-5.4-mini        - Triage, small edits, sidecar/subagent workers,
#                         cost-sensitive loops (Tier 2 Light, effort=low|medium)
#   gpt-5.2             - Deep root-cause debugging / long deliberation
#                         (Tier 2 Deep-Debug alt, effort=high)
#   gpt-5.3-codex-spark - Ultra-rapid iterative code edits (Tier 2.5,
#                         ChatGPT Pro plans only, research preview)
#
# RETIRED (no longer in /codex/models as of April 2026 — do NOT use):
#   gpt-5.2-codex, gpt-5.1-codex, gpt-5.1-codex-max, gpt-5-codex-mini
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
#   # With explicit model + effort override:
#   bash scripts/aop-codex-dispatch.sh \
#     /c/ai/temp/AOP_PROMPT_task1.md \
#     /c/ai/temp/AOP_COMPLETE_task1.json \
#     /c/ai/claude-intelligence-hub \
#     gpt-5.3-codex \
#     xhigh
# ============================================================

set -euo pipefail

USAGE="Usage: aop-codex-dispatch.sh <prompt_file> <artifact_path> [working_dir] [model] [effort]"
PROMPT_FILE="${1:?$USAGE}"
ARTIFACT_PATH="${2:?$USAGE}"
WORKING_DIR="${3:-$(pwd)}"
MODEL="${4:-gpt-5.4}"
EFFORT="${5:-medium}"

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
echo "Effort:    $EFFORT"
echo "Time:      $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "=========================="

# Inject Python artifact generation reminder into prompt
# PowerShell strips double quotes from bash heredoc — Python json.dumps() is immune (FND-0045)
PATCHED_PROMPT=$(mktemp)
cat "$PROMPT_FILE" > "$PATCHED_PROMPT"
cat >> "$PATCHED_PROMPT" << 'ARTIFACT_PATCH'

---
IMPORTANT — ARTIFACT GENERATION RULE:
Write the AOP completion artifact using Python json.dumps(), NOT bash heredoc.
Bash heredoc on Windows/PowerShell produces malformed JSON (stripped quotes).
Use: python3 -c "import json; ..." to write the artifact file.
Do NOT use: cat > artifact.json << 'EOF' ... EOF
---
ARTIFACT_PATCH

# Read patched prompt and pass to codex exec via stdin
# Note: --dangerously-bypass-approvals-and-sandbox is the long form of --yolo (identical behavior).
# The long form is used here for explicit auditability in CI/script logs.
# Effort is passed via -c model_reasoning_effort="..." (the only documented CLI way, post-FND-0078).
cat "$PATCHED_PROMPT" | codex exec \
  --model "$MODEL" \
  --dangerously-bypass-approvals-and-sandbox \
  -c "model_reasoning_effort=\"$EFFORT\"" \
  -C "$WORKING_DIR"

# Cleanup patched prompt
rm -f "$PATCHED_PROMPT"

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
