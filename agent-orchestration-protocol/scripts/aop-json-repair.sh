#!/usr/bin/env bash
# ============================================================
# aop-json-repair.sh — Post-execution JSON artifact repair
#
# Purpose: Attempts to repair malformed AOP completion artifacts
#          caused by PowerShell escaping on Windows (FND-0045).
#          This is a FALLBACK — Python-based artifact generation
#          is the preferred solution.
#
# Usage:
#   bash scripts/aop-json-repair.sh <artifact_path>
#
# What it repairs:
#   - Unquoted keys:    { status: SUCCESS } → { "status": "SUCCESS" }
#   - Trailing commas:  {"a": 1,} → {"a": 1}
#   - Single quotes:    {'status': 'SUCCESS'} → {"status": "SUCCESS"}
#
# What it does NOT repair:
#   - Truncated files (missing closing braces)
#   - Binary corruption
#   - Completely empty files
#
# Exit codes:
#   0 — artifact is valid JSON (either already valid or repaired)
#   1 — repair failed, artifact is still invalid
#   2 — file not found or empty
# ============================================================

set -euo pipefail

ARTIFACT="${1:?Usage: aop-json-repair.sh <artifact_path>}"

if [ ! -f "$ARTIFACT" ]; then
  echo "ERROR: Artifact not found: $ARTIFACT" >&2
  exit 2
fi

if [ ! -s "$ARTIFACT" ]; then
  echo "ERROR: Artifact is empty: $ARTIFACT" >&2
  exit 2
fi

# Check if already valid JSON
if python3 -c "import json; json.load(open('$ARTIFACT'))" 2>/dev/null; then
  echo "OK: Artifact is valid JSON — no repair needed."
  exit 0
fi

echo "WARN: Artifact is malformed. Attempting repair..."

# Attempt Python-based repair
python3 - "$ARTIFACT" << 'REPAIR_SCRIPT'
import json
import re
import sys

artifact_path = sys.argv[1]

with open(artifact_path, 'r', encoding='utf-8') as f:
    raw = f.read().strip()

if not raw:
    print("ERROR: Empty content", file=sys.stderr)
    sys.exit(1)

# Repair pass 1: Replace single quotes with double quotes
repaired = raw.replace("'", '"')

# Repair pass 2: Quote unquoted keys — { status: "SUCCESS" } → { "status": "SUCCESS" }
repaired = re.sub(r'(?<=[{,])\s*(\w+)\s*:', r' "\1":', repaired)

# Repair pass 3: Remove trailing commas before } or ]
repaired = re.sub(r',\s*([}\]])', r'\1', repaired)

# Validate the repaired JSON
try:
    parsed = json.loads(repaired)
    with open(artifact_path, 'w', encoding='utf-8') as f:
        json.dump(parsed, f, indent=2)
    print("REPAIRED: Artifact fixed and rewritten as valid JSON.")
    sys.exit(0)
except json.JSONDecodeError as e:
    print(f"REPAIR FAILED: Could not fix JSON — {e}", file=sys.stderr)
    print(f"Content preview: {raw[:300]}", file=sys.stderr)
    sys.exit(1)
REPAIR_SCRIPT
