#!/usr/bin/env bash
# ============================================================
# aop-post-audit.sh — Post-execution write scope audit
# ============================================================
#
# Purpose:  After all executors complete, runs a per-executor
#           git diff and compares actual writes against each
#           executor's declared write scope. Any file written
#           outside scope is flagged as a security incident.
#
# Usage:    bash scripts/aop-post-audit.sh <project_dir> \
#             "task_id:write_scope" [...]
#
# Dependencies: bash 4+, git
#
# Example:
#   bash scripts/aop-post-audit.sh /c/ai/project \
#     "feature-auth:/c/ai/project/src/auth/" \
#     "feature-ui:/c/ai/project/src/ui/"
#
# Exit codes:
#   0 — all writes within declared scopes
#   1 — security incident (out-of-scope writes detected)
# ============================================================
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <project_dir> 'task_id:write_scope' [...]" >&2
  exit 1
fi

PROJECT_DIR="$1"
shift

incidents=0

for arg in "$@"; do
  TASK="${arg%%:*}"
  SCOPE="${arg#*:}"

  echo "=== Auditing executor: ${TASK} ==="
  CHANGED=$(git -C "$PROJECT_DIR" diff --name-only HEAD~1)

  # Strip project dir prefix from scope for comparison
  SCOPE_REL=$(echo "$SCOPE" | sed "s|${PROJECT_DIR}/||")

  OUT_OF_SCOPE=$(echo "$CHANGED" | grep -v "^${SCOPE_REL}" || true)

  if [ -n "$OUT_OF_SCOPE" ]; then
    echo "SECURITY INCIDENT: Files written outside scope for ${TASK}:"
    echo "$OUT_OF_SCOPE"
    incidents=$((incidents + 1))
  else
    echo "PASS: all writes within declared scope."
  fi
done

if [ "$incidents" -gt 0 ]; then
  echo "AUDIT FAILED: ${incidents} executor(s) wrote outside scope."
  exit 1
fi

echo "AUDIT PASSED: all executors within scope."
exit 0
